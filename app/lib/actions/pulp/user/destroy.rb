module Actions
  module Pulp
    module User
      class Destroy < Pulp::Abstract
        input_format do
          param :remote_id, String
        end

        def run
          output[:response] = pulp_resources.user.delete(input.fetch(:remote_id))
        end
      end
    end
  end
end
