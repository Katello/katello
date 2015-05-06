module Actions
  module Pulp
    module Consumer
      class ActivateNode < Pulp::Abstract
        input_format do
          param :uuid, String
        end

        def plan(system)
          plan_self(:uuid => system.uuid, :display_name => system.name)
        end

        def run
          ::Katello.pulp_server.extensions.consumer.activate_node(input[:uuid], 'mirror')
        end
      end
    end
  end
end
