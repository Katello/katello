module Actions
  module Pulp
    module Consumer
      class Update < Pulp::Abstract
        input_format do
          param :uuid, String
          param :display_name, String
        end

        def plan(system)
          plan_self(:uuid => system.uuid, :display_name => system.name)
        end

        def run
          ::Katello.pulp_server.extensions.consumer.update(input[:uuid], :display_name => input[:name])
        end
      end
    end
  end
end
