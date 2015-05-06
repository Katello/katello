module Actions
  module Pulp
    module Consumer
      class Create < Pulp::Abstract
        include Helpers::Presenter

        input_format do
          param :uuid, String
          param :name, String
        end

        def run
          output[:response] = pulp_extensions.consumer.create(input[:uuid],
                                                               display_name: input[:name])
        end
      end
    end
  end
end
