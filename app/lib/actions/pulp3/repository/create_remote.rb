module Actions
  module Pulp3
    module Repository
      class CreateRemote < Pulp3::Abstract
        def plan(repository, smart_proxy)
          repository.backend_service(smart_proxy).create_remote if repository.root.url?
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
