# rubocop:disable Lint/SuppressedException
module Actions
  module Katello
    module ContentView
      class PromoteToEnvironment < Actions::EntryAction
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
                plan_action(Repository::Destroy, repo, :skip_environment_update => true)
              end
            end
            plan_action(Candlepin::Environment::SetContent, version.content_view, environment, version.content_view.content_view_environment(environment))
            plan_action(Katello::Foreman::ContentUpdate, environment, version.content_view)
            plan_action(ContentView::ErrataMail, version.content_view, environment)
            plan_self(history_id: history.id, environment_id: environment.id, user_id: ::User.current.id,
                      environment_name: environment.name, content_view_id: version.content_view.id)
          end
        end

        def humanized_name
          _("Promotion to Environment")
        end

        def rescue_strategy_for_self
          Dynflow::Action::Rescue::Skip
        end

        def finalize
          # update errata applicability counts for all hosts in the CV & LE
          ::Katello::Host::ContentFacet.where(:content_view_id => input[:content_view_id],
                                              :lifecycle_environment_id => input[:environment_id]).each do |facet|
            facet.update_applicability_counts
            facet.update_errata_status
          end

          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
          environment = ::Katello::KTEnvironment.find(input[:environment_id])

          if ::SmartProxy.sync_needed?(environment) && Setting[:foreman_proxy_content_auto_sync]
            ForemanTasks.async_task(ContentView::CapsuleSync,
                                    ::Katello::ContentView.find(input[:content_view_id]),
                                    environment)
          end
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
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
