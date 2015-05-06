module Actions
  module Pulp
    module Superuser
      class Abstract < Pulp::Abstract
        input_format do
          param :remote_id, String
          param :pulp_user, String
        end

        def run
          output[:response] = pulp_resources.role.
              send(operation, 'super-users', input[:remote_id])
        end

        private

        def operation
          fail NotImplementedError
        end
      end
    end
  end
end
