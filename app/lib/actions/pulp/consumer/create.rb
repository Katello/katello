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
          response =  pulp_extensions.consumer.create(input[:uuid], display_name: input[:name])
          output[:response] = response.slice(:uuid, :name)
        end
      end
    end
  end
end
