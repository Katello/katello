module Actions
  module Katello
    module Repository
      class IndexContent < Actions::EntryAction
        def plan(repo, index_args)
          plan_action(PulpSelector,
                      [Actions::Pulp::Repository::Index,
                       Actions::Pulp3::Repository::Index],
                       repo, SmartProxy.pulp_master, index_args)
        end
      end
    end
  end
end
