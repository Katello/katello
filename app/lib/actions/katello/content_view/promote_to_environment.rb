# rubocop:disable HandleExceptions
module Actions
  module Katello
    module ContentView
      class PromoteToEnvironment < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(version, environment, description)
          history = ::Katello::ContentViewHistory.create!(:content_view_version => version, :user => ::User.current.login,
                                                          :environment => environment, :task => self.task,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :action => 'promotion',
                                                          :notes => description)

          sequence do
            plan_action(ContentView::AddToEnvironment, version, environment)
            concurrence do
              version.archived_repos.non_puppet.each do |repository|
                sequence do
                  plan_action(Repository::CloneToEnvironment, repository, environment)
                end
              end

              plan_action(ContentViewPuppetEnvironment::Clone, version, :environment => environment,
                          :puppet_modules_present => version.promote_puppet_environment?)

              repos_to_delete(version, environment).each do |repo|
                plan_action(Repository::Destroy, repo, :skip_environment_update => true, :planned_destroy => true)
              end
            end

            plan_action(ContentView::UpdateEnvironment, version.content_view, environment)
            plan_action(Katello::Foreman::ContentUpdate, environment, version.content_view)
            plan_action(ContentView::ErrataMail, version.content_view, environment)
            plan_self(history_id: history.id, environment_id: environment.id, user_id: ::User.current.id,
                      environment_name: environment.name, content_view_id: version.content_view.id)
          end
        end

        def humanized_name
          _("Promotion to Environment")
        end

        def run
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          if ::Katello::CapsuleContent.sync_needed?(environment)
            ForemanTasks.async_task(ContentView::CapsuleGenerateAndSync,
                                    ::Katello::ContentView.find(input[:content_view_id]),
                                    environment)
          end
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end

        def finalize
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        private

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
