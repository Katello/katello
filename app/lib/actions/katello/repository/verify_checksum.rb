module Actions
  module Katello
    module Repository
      class VerifyChecksum < Actions::EntryAction
        include Helpers::Presenter

        def plan(repo)
          action_subject(repo)

          if SmartProxy.pulp_primary.pulp3_support?(repo)
            plan_action(Actions::Pulp3::Repository::Repair, repo.id, SmartProxy.pulp_primary)
          else
            options = {}
            options[:validate_contents] = true
            plan_action(Actions::Katello::Repository::Sync, repo, options)
          end
        end

        def presenter
          found = all_planned_actions(Katello::Repository::Sync)
          found = all_planned_actions(Pulp3::Repository::Repair) if found.empty?
          Helpers::Presenter::Delegated.new(self, found)
        end
      end
    end
  end
end
