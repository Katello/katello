# rubocop:disable HandleExceptions
module Actions
  module Katello
    module ContentView
      class Publish < Actions::EntryAction
        # rubocop:disable MethodLength
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

          if options[:minor] && options[:major]
            version = content_view.create_new_version(options[:major], options[:minor])
          else
            version = content_view.create_new_version
          end

          library = content_view.organization.library
          history = ::Katello::ContentViewHistory.create!(:content_view_version => version,
                                                          :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :action => ::Katello::ContentViewHistory.actions[:publish],
                                                          :task => self.task,
                                                          :notes => description,
                                                          :triggered_by => options[:triggered_by]
                                                         )

          sequence do
            plan_action(ContentView::AddToEnvironment, version, library)
            concurrence do
              content_view.publish_repositories do |repositories|
                sequence do
                  clone_to_version = plan_action(Repository::CloneToVersion, repositories, version,
                                                 :repos_units => options[:repos_units])
                  plan_action(Repository::CloneToEnvironment, clone_to_version.new_repository, library)
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
                      content_view_version_id: version.id,
                      environment_id: library.id, user_id: ::User.current.id)
          end
        end

        def humanized_name
          _("Publish")
        end

        def run
          view = ::Katello::ContentView.find(input[:content_view_id])
          version = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          output[:content_view_id] = view.id
          output[:content_view_version_id] = version.id
          unless view.composite?
            output[:composite_version_auto_published] = []
            output[:composite_view_publish_failed] = []
            output[:composite_auto_publish_task_id] = []

            # Iterate through the list of composites
            # this component belongs to
            view.component_composites.each do |cv_component|
              if cv_component.latest? && cv_component.composite_content_view.auto_publish?
                description = _("Auto Publish - Triggered by '%{component}'") %
                                { :component => version.name }
                begin
                  task = ForemanTasks.async_task(::Actions::Katello::ContentView::Publish,
                                          cv_component.composite_content_view,
                                          description,
                                          :triggered_by => version)
                  output[:composite_auto_publish_task_id] << task.id
                  output[:composite_version_auto_published] << task.input[:content_view_version_id]
                rescue StandardError
                  ::Katello::UINotifications::ContentView::AutoPublishFailure.deliver!(
                                              cv_component.composite_content_view)
                  output[:composite_view_publish_failed] << cv_component.composite_content_view.id
                end
              end
            end
          end
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end

        def finalize
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
      end
    end
  end
end
