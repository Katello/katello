# rubocop:disable HandleExceptions
module Actions
  module Katello
    module ContentView
      class Publish < Actions::EntryAction
        # rubocop:disable MethodLength,Metrics/AbcSize
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

          version = version_for_publish(content_view, options)
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
          content_view.publish_repositories do |repositories|
            source_repositories += [repositories]
          end

          sequence do
            plan_action(ContentView::AddToEnvironment, version, library)
            repository_mapping = plan_action(ContentViewVersion::CreateRepos, version, source_repositories).repository_mapping

            concurrence do
              source_repositories.each do |repositories|
                sequence do
                  plan_action(Repository::CloneToVersion, repositories, version, repository_mapping[repositories],
                                                 :repos_units => options[:repos_units])
                  plan_action(Repository::CloneToEnvironment, repository_mapping[repositories], library)
                end
              end

              repos_to_delete(content_view).each do |repo|
                plan_action(Repository::Destroy, repo, :skip_environment_update => true)
              end
            end
            has_modules = content_view.publish_puppet_environment?
            plan_action(ContentViewPuppetEnvironment::CreateForVersion, version)
            plan_action(ContentViewPuppetEnvironment::Clone, version, :environment => library,
                :puppet_modules_present => has_modules)
            plan_action(Candlepin::Environment::SetContent, content_view, library, content_view.content_view_environment(library))
            plan_action(Katello::Foreman::ContentUpdate, library, content_view)
            plan_action(ContentView::ErrataMail, content_view, library)
            plan_self(history_id: history.id, content_view_id: content_view.id,
                      auto_publish_composite_ids: auto_publish_composite_ids(content_view),
                      content_view_version_name: version.name,
                      content_view_version_id: version.id,
                      environment_id: library.id, user_id: ::User.current.id)
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
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end

        def finalize
          version = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          version.update_content_counts!
          # update errata applicability counts for all hosts in the CV & Library
          ::Katello::Host::ContentFacet.where(:content_view_id => input[:content_view_id],
                                              :lifecycle_environment_id => input[:environment_id]).each do |facet|
            facet.update_applicability_counts
          end

          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          view = ::Katello::ContentView.find(input[:content_view_id])
          if SmartProxy.sync_needed?(environment) && Setting[:foreman_proxy_content_auto_sync]
            ForemanTasks.async_task(ContentView::CapsuleSync,
                                    view,
                                    environment)
          end
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        private

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
            content_view.create_new_version(options[:major], options[:minor])
          else
            content_view.create_new_version
          end
        end
      end
    end
  end
end
