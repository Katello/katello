module Actions
  module Pulp
    module Consumer
      class DeactivateNode < Pulp::Abstract
        input_format do
          param :uuid, String
        end

        def plan(system)
          plan_self(:uuid => system.uuid, :display_name => system.name)
        end

        def run
          ::Katello.pulp_server.extensions.consumer.deactivate_node(input[:uuid])
        end
      end
    end
  end
end
