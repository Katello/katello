module Actions
  module Katello
    module ContentView
      class PromoteToEnvironment < Actions::EntryAction
        execution_plan_hooks.use :trigger_capsule_sync, :on => :success
        def plan(version, environment, description, incremental_update = false)
          history = ::Katello::ContentViewHistory.create!(:content_view_version => version, :user => ::User.current.login,
                                                          :environment => environment, :task => self.task,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :action => 'promotion',
                                                          :notes => description)

          sequence do
            plan_action(ContentView::AddToEnvironment, version, environment)
            concurrence do
              version.archived_repos.each do |repository|
                sequence do
                  plan_action(Repository::CloneToEnvironment, repository, environment)
                end
              end

              repos_to_delete(version, environment).each do |repo|
                plan_action(Repository::Destroy, repo, :skip_environment_update => true)
              end
            end
            plan_action(Candlepin::Environment::SetContent, version.content_view, environment, version.content_view.content_view_environment(environment))
            plan_action(Katello::Foreman::ContentUpdate, environment, version.content_view)
            plan_action(ContentView::ErrataMail, version.content_view, environment)

            if incremental_update && sync_proxies?(environment)
              plan_action(ContentView::CapsuleSync, version.content_view, environment)
            end

            plan_self(history_id: history.id, environment_id: environment.id, user_id: ::User.current.id,
                      environment_name: environment.name, content_view_id: version.content_view.id, incremental_update: incremental_update)
          end
        end

        def humanized_name
          _("Promotion to Environment")
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end

        def finalize
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          ::Katello::ContentView.find(input[:content_view_id]).update_host_statuses(environment)

          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        def trigger_capsule_sync(_execution_plan)
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          if !input[:incremental_update] && sync_proxies?(environment)
            ForemanTasks.async_task(ContentView::CapsuleSync,
                                    ::Katello::ContentView.find(input[:content_view_id]),
                                    environment)
          end
        end

        private

        def sync_proxies?(environment)
          ::SmartProxy.sync_needed?(environment)
        end

        def repos_to_delete(version, environment)
          archived_library_instance_ids = version.archived_repos.collect { |archived| archived.library_instance_id }
          version.content_view.repos(environment).find_all do |repo|
            !archived_library_instance_ids.include?(repo.library_instance_id)
          end
        end
      end
    end
  end
end
