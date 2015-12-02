module Actions
  module Candlepin
    module Consumer
      class Create < Candlepin::Abstract
        input_format do
          param :cp_environment_id
          param :consumer_parameters
          param :activation_keys
        end

        # We need to call this in plan phase as this can lean to error responses
        # when the activation key fails to subscribe to the products
        def plan(input)
          response = ::Katello::Resources::Candlepin::Consumer.create(input[:cp_environment_id],
                     input[:consumer_parameters], input[:activation_keys])
          plan_self(input.merge(response: response.slice(:uuid, :name)))
        end

        def run
          # we still keep the output interface the same for case there is other
          # way how to check the ability to subscribe the system with the actiovation key
          # or we have better support for rolling back in Dynflow
          output[:response] = input[:response]
        end
      end
    end
  end
end
