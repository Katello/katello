module Actions
  module Katello
    module ContentView
      class Remove < Actions::EntryAction
        include Helpers::ContentViewAutoPublisher

        # Remove content view versions and/or environments from a content view

        # Options: (note that all are optional)
        # content_view_environments - content view environments to delete
        # content_view_versions - view versions to delete
        # system_content_view_id - content view to reassociate systems with
        # system_environment_id - environment to reassociate systems with
        # key_content_view_id - content view to reassociate actvation keys with
        # key_environment_id - environment to reassociate activation keys with
        # hostgroup_content_view_environment_id - content view environment to reassociate host groups with
        # destroy_content_view - delete the CV completely along with all cv versions and environments
        # organization_destroy
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity
        def plan(content_view, options)
          cvenvs = options.fetch(:content_view_environments, [])
          versions = options.fetch(:content_view_versions, [])
          organization_destroy = options.fetch(:organization_destroy, false)
          skip_repo_destroy = options.fetch(:skip_repo_destroy, false)
          action_subject(content_view)
          validate_options(content_view, cvenvs, versions, options) unless organization_destroy

          all_cvenvs = combined_cvenvs(cvenvs, versions)
          check_version_deletion(versions, cvenvs)

          sequence do
            unless organization_destroy
              concurrence do
                all_cvenvs.each do |cvenv|
                  if cvenv.hosts.any? || cvenv.activation_keys.any? || cvenv.hostgroups.any?
                    plan_action(ContentViewEnvironment::ReassignObjects, cvenv, options)
                  end
                end
              end
            end

            cv_histories = []
            all_cvenvs.each do |cvenv|
              cv_histories << ::Katello::ContentViewHistory.create!(:content_view_version => cvenv.content_view_version,
                                                                    :user => ::User.current.login,
                                                                    :environment => cvenv.environment,
                                                                    :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                                    :action => ::Katello::ContentViewHistory.actions[:removal],
                                                                    :task => self.task)
              plan_action(ContentViewEnvironment::Destroy,
                          cvenv,
                          :skip_repo_destroy => skip_repo_destroy,
                          :organization_destroy => organization_destroy)
            end

            versions.each do |version|
              ::Katello::ContentViewHistory.create!(:content_view_version => version,
                                                    :user => ::User.current.login,
                                                    :action => ::Katello::ContentViewHistory.actions[:removal],
                                                    :status => ::Katello::ContentViewHistory::IN_PROGRESS, :task => self.task)
              plan_action(ContentViewVersion::Destroy, version,
                          :skip_environment_check => true,
                          :skip_destroy_env_content => true)
            end
            if options[:destroy_content_view] && SmartProxy.pulp_primary&.pulp3_enabled?
              plan_action(Actions::Pulp3::ContentView::DeleteRepositoryReferences, content_view, SmartProxy.pulp_primary)
            end
            plan_self(content_view_id: content_view.id,
                      destroy_content_view: options[:destroy_content_view],
                      environment_ids: cvenvs.map(&:environment_id),
                      environment_names: cvenvs.map { |cvenv| cvenv.environment.name },
                      version_ids: versions.map(&:id),
                      content_view_history_ids: cv_histories.map { |history| history.id })

            if organization_destroy
              destroy_host_and_hostgroup_associations(content_view: content_view)
            end
          end
        end

        def destroy_host_and_hostgroup_associations(content_view:)
          # Destroy hostgroup content facets associated with this content view
          hostgroup_content_facet_ids = content_view.hostgroup_content_facets.ids
          ::Katello::Hostgroup::ContentFacet.where(:id => hostgroup_content_facet_ids).destroy_all

          host_ids = content_view.hosts.ids
          ::Katello::Host::ContentFacet.where(:host_id => host_ids).destroy_all
          ::Katello::Host::SubscriptionFacet.where(:host_id => host_ids).destroy_all
        end

        def check_version_deletion(versions, cvenvs)
          versions.each do |version|
            version.environments.each do |env|
              if cvenvs.none? { |cvenv| cvenv.content_view_version == version && cvenv.environment == env }
                fail _("Cannot delete version while it is in environment %s") % env.name
              end
            end
          end
        end

        def humanized_name
          _("Remove Versions and Associations")
        end

        def finalize
          if input[:destroy_content_view]
            content_view = ::Katello::ContentView.find(input[:content_view_id])
            content_view.content_view_repositories.each(&:destroy)
            content_view.destroy!
          else
            input[:content_view_history_ids].each do |history_id|
              history = ::Katello::ContentViewHistory.find_by(:id => history_id)
              if history
                history.status = ::Katello::ContentViewHistory::SUCCESSFUL
                history.save!
              end
            end
          end
        end

        def validate_options(_content_view, cvenvs, versions, options)
          if !options[:destroy_content_view] && cvenvs.empty? && versions.empty?
            fail _("Either environments or versions must be specified.")
          end
          all_cvenvs = combined_cvenvs(cvenvs, versions)

          single_env_hosts_exist = all_cvenvs.flat_map(&:hosts).any? do |host|
            !host.content_facet.multi_content_view_environment?
          end
          if single_env_hosts_exist && !cvenv_exists?(options[:system_environment_id], options[:system_content_view_id])
            fail _("Unable to reassign systems. Please check system_content_view_id and system_environment_id.")
          end

          single_env_keys_exist = all_cvenvs.flat_map(&:activation_keys).any? do |key|
            !key.multi_content_view_environment?
          end
          if single_env_keys_exist && !cvenv_exists?(options[:key_environment_id], options[:key_content_view_id])
            fail _("Unable to reassign activation_keys. Please check activation_key_content_view_id and activation_key_environment_id.")
          end

          hostgroups_exist = all_cvenvs.flat_map(&:hostgroups).any?
          if hostgroups_exist && !cvenv_exists_by_id?(options[:hostgroup_content_view_environment_id])
            fail _("Unable to reassign host groups. Please check hostgroup_content_view_environment_id.")
          end
        end

        def combined_cvenvs(cvenvs, versions)
          (cvenvs + versions.flat_map(&:content_view_environments)).uniq
        end

        def cvenv_exists?(environment_id, content_view_id)
          ::Katello::ContentViewEnvironment.where(:environment_id => environment_id,
                                                  :content_view_id => content_view_id
                                                 ).exists?
        end

        def cvenv_exists_by_id?(cvenv_id)
          ::Katello::ContentViewEnvironment.where(:id => cvenv_id).exists?
        end
      end
    end
  end
end
