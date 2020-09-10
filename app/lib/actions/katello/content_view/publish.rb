# rubocop:disable Lint/SuppressedException
module Actions
  module Katello
    module ContentView
      class Publish < Actions::EntryAction
        include ::Katello::ContentViewHelper
        attr_accessor :version
        # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
        def plan(content_view, description = "", options = {})
          action_subject(content_view)
          content_view.check_ready_to_publish!

          if options[:repos_units].present?
            valid_labels_from_cv = content_view.repositories.map(&:label)
            labels_from_repos_units = options[:repos_units].map { |repo| repo[:label] }

            labels_from_repos_units.each do |label|
              fail _("Repository label '%s' is not associated with content view.") % label unless valid_labels_from_cv.include? label
            end

            valid_labels_from_cv.each do |label|
              fail _("Content view has repository label '%s' which is not specified in repos_units parameter.") % label unless labels_from_repos_units.include? label
            end
          end

          # Add non-override components back in
          options[:override_components] = include_other_components(options[:override_components], content_view)

          version = version_for_publish(content_view, options)
          self.version = version
          library = content_view.organization.library
          history = ::Katello::ContentViewHistory.create!(:content_view_version => version,
                                                          :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :action => ::Katello::ContentViewHistory.actions[:publish],
                                                          :task => self.task,
                                                          :notes => description,
                                                          :triggered_by => options[:triggered_by]
                                                         )
          source_repositories = []
          content_view.publish_repositories(options[:override_cvvs]) do |repositories|
            source_repositories += [repositories]
          end

          sequence do
            plan_action(ContentView::AddToEnvironment, version, library) unless options[:skip_promotion]
            repository_mapping = plan_action(ContentViewVersion::CreateRepos, version, source_repositories).repository_mapping

            # Split Pulp 3 Yum repos out of the repository_mapping.  Only Pulp 3 RPM plugin has multi repo copy support.
            separated_repo_map = separated_repo_mapping(repository_mapping)

            if separated_repo_map[:pulp3_yum].keys.flatten.present? &&
                SmartProxy.pulp_primary.pulp3_support?(separated_repo_map[:pulp3_yum].keys.flatten.first)
              plan_action(Repository::MultiCloneToVersion, separated_repo_map[:pulp3_yum], version)
            end

            concurrence do
              source_repositories.each do |repositories|
                sequence do
                  if repositories.present? && separated_repo_map[:other].keys.include?(repositories)
                    plan_action(Repository::CloneToVersion, repositories, version, repository_mapping[repositories],
                                :repos_units => options[:repos_units])
                  end
                  plan_action(Repository::CloneToEnvironment, repository_mapping[repositories], library) unless options[:skip_promotion]
                end
              end

              repos_to_delete(content_view).each do |repo|
                plan_action(Repository::Destroy, repo, :skip_environment_update => true)
              end
            end

            if SmartProxy.pulp_primary.has_feature?(SmartProxy::PULP_FEATURE)
              has_modules = content_view.publish_puppet_environment?
              plan_action(ContentViewPuppetEnvironment::CreateForVersion, version)
              unless options[:skip_promotion]
                plan_action(ContentViewPuppetEnvironment::Clone, version, :environment => library,
                    :puppet_modules_present => has_modules)
              end
            end
            plan_action(Candlepin::Environment::SetContent, content_view, library, content_view.content_view_environment(library)) unless options[:skip_promotion]
            plan_action(Katello::Foreman::ContentUpdate, library, content_view) unless options[:skip_promotion]
            plan_action(ContentView::ErrataMail, content_view, library) unless options[:skip_promotion]

            plan_self(history_id: history.id, content_view_id: content_view.id,
                      auto_publish_composite_ids: auto_publish_composite_ids(content_view),
                      content_view_version_name: version.name,
                      content_view_version_id: version.id,
                      environment_id: library.id, user_id: ::User.current.id, skip_promotion: options[:skip_promotion])
          end
        end

        def humanized_name
          _("Publish")
        end

        def run
          metadata = {
            description: _("Auto Publish - Triggered by '%s'") % input[:content_view_version_name],
            triggered_by: input[:content_view_version_id]
          }
          input[:auto_publish_composite_ids].each do |composite_id|
            ::Katello::EventQueue.push_event(::Katello::Events::AutoPublishCompositeView::EVENT_TYPE, composite_id) do |attrs|
              attrs[:metadata] = metadata
            end
          end

          output[:content_view_id] = input[:content_view_id]
          output[:content_view_version_id] = input[:content_view_version_id]
          output[:skip_promotion] = input[:skip_promotion]
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end

        def finalize
          version = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          version.update_content_counts!
          # update errata applicability counts for all hosts in the CV & Library
          unless input[:skip_promotion]
            ::Katello::Host::ContentFacet.where(:content_view_id => input[:content_view_id],
                                                :lifecycle_environment_id => input[:environment_id]).each do |facet|
              facet.update_applicability_counts
            end
          end

          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          view = ::Katello::ContentView.find(input[:content_view_id])
          if SmartProxy.sync_needed?(environment) && Setting[:foreman_proxy_content_auto_sync] && !input[:skip_promotion]
            ForemanTasks.async_task(ContentView::CapsuleSync,
                                    view,
                                    environment)
          end
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        private

        def include_other_components(override_components, content_view)
          if override_components.present?
            content_view.components.each do |component|
              component_has_override = override_components.detect do |override_component|
                component.content_view_id == override_component.content_view_id
              end
              unless component_has_override
                override_components << component
              end
            end
            override_components
          end
        end

        def repos_to_delete(content_view)
          if content_view.composite?
            library_instances = content_view.repositories_to_publish.map(&:library_instance_id)
          else
            library_instances = content_view.repositories_to_publish.map(&:id)
          end
          content_view.repos(content_view.organization.library).find_all do |repo|
            !library_instances.include?(repo.library_instance_id)
          end
        end

        def auto_publish_composite_ids(content_view)
          content_view.auto_publish_components.pluck(:composite_content_view_id)
        end

        def version_for_publish(content_view, options)
          if options[:minor] && options[:major]
            if options[:override_components]
              content_view.create_new_version(options[:major], options[:minor], options[:override_components])
            else
              content_view.create_new_version(options[:major], options[:minor])
            end
          else
            content_view.create_new_version
          end
        end
      end
    end
  end
end
