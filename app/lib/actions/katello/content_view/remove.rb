module Actions
  module Katello
    module ContentView
      class Remove < Actions::EntryAction
        # Remove content view versions and/or environments from a content view

        # Options: (note that all are optional)
        # content_view_environments - content view environments to delete
        # content_view_versions - view versions to delete
        # system_content_view_id - content view to reassociate systems with
        # system_environment_id - environment to reassociate systems with
        # key_content_view_id - content view to reassociate actvation keys with
        # key_environment_id - environment to reassociate activation keys with'
        # organization_destroy
        # rubocop:disable MethodLength
        def plan(content_view, options)
          cv_envs = options.fetch(:content_view_environments, [])
          versions = options.fetch(:content_view_versions, [])
          organization_destroy = options.fetch(:organization_destroy, false)
          skip_repo_destroy = options.fetch(:skip_repo_destroy, false)
          action_subject(content_view)
          validate_options(content_view, cv_envs, versions, options) unless organization_destroy

          all_cv_envs = combined_cv_envs(cv_envs, versions)
          check_version_deletion(versions, cv_envs)

          sequence do
            unless organization_destroy
              concurrence do
                all_cv_envs.each do |cv_env|
                  if cv_env.systems.any? || cv_env.activation_keys.any?
                    plan_action(ContentViewEnvironment::ReassignObjects, cv_env, options)
                  end
                end
              end
            end

            cv_histories = []
            all_cv_envs.each do |cve|
              cv_histories << ::Katello::ContentViewHistory.create!(:content_view_version => cve.content_view_version,
                                                                    :user => ::User.current.login,
                                                                    :environment => cve.environment,
                                                                    :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                                    :task => self.task)
              plan_action(ContentViewEnvironment::Destroy,
                          cve,
                          :skip_repo_destroy => skip_repo_destroy,
                          :organization_destroy => organization_destroy)
            end

            versions.each do |version|
              ::Katello::ContentViewHistory.create!(:content_view_version => version,
                                                    :user => ::User.current.login,
                                                    :status => ::Katello::ContentViewHistory::IN_PROGRESS, :task => self.task)
              plan_action(ContentViewVersion::Destroy, version,
                          :skip_environment_check => true,
                          :skip_destroy_env_content => true)
            end

            plan_self(content_view_id: content_view.id,
                      environment_ids: cv_envs.map(&:environment_id),
                      environment_names: cv_envs.map { |cve| cve.environment.name },
                      version_ids: versions.map(&:id),
                      content_view_history_ids: cv_histories.map { |history| history.id })
          end
        end

        def check_version_deletion(versions, cv_envs)
          versions.each do |version|
            version.environments.each do |env|
              if cv_envs.none? { |cv_env| cv_env.content_view_version == version && cv_env.environment == env }
                fail _("Cannot delete version while it is in environment %s") % env.name
              end
            end
          end
        end

        def humanized_name
          _("Remove Versions and Associations")
        end

        def finalize
          input[:content_view_history_ids].each do |history_id|
            history = ::Katello::ContentViewHistory.find_by_id(history_id)
            if history
              history.status = ::Katello::ContentViewHistory::SUCCESSFUL
              history.save!
            end
          end
        end

        def validate_options(_content_view, cv_envs, versions, options)
          if cv_envs.empty? && versions.empty?
            fail _("Either environments or versions must be specified.")
          end
          all_cv_envs = combined_cv_envs(cv_envs, versions)

          if all_cv_envs.flat_map(&:systems).any? && system_cve(options).nil?
            fail _("Unable to reassign systems. Please check system_content_view_id and system_environment_id.")
          end

          if all_cv_envs.flat_map(&:activation_keys).any? && activation_key_cve(options).nil?
            fail _("Unable to reassign activation_keys. Please check activation_key_content_view_id and activation_key_environment_id.")
          end
        end

        def combined_cv_envs(cv_envs, versions)
          (cv_envs + versions.flat_map(&:content_view_environments)).uniq
        end

        def system_cve(options)
          ::Katello::ContentViewEnvironment.where(:environment_id => options[:system_environment_id],
                                                  :content_view_id => options[:system_content_view_id]
                                      ).first
        end

        def activation_key_cve(options)
          ::Katello::ContentViewEnvironment.where(:environment_id => options[:key_environment_id],
                                                  :content_view_id => options[:key_content_view_id]
                                      ).first
        end
      end
    end
  end
end
