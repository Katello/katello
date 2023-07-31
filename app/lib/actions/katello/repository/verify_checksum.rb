module Actions
  module Katello
    module Repository
      class VerifyChecksum < Actions::EntryAction
        include Helpers::Presenter

        def plan(repo)
          action_subject(repo)
          plan_action(Actions::Pulp3::Repository::Repair, repo.id, SmartProxy.pulp_primary)
        end

        def presenter
          found = all_planned_actions(Pulp3::Repository::Repair)
          Helpers::Presenter::Delegated.new(self, found)
        end
      end
    end
  end
end
