module Actions
  module Pulp
    module User
      class Create < Pulp::Abstract
        input_format do
          param :remote_id, String
        end

        def run
          user_params = { name: input[:remote_id],
                          password: Password.generate_random_string(16) }
          output[:response] = pulp_resources.user.create(input[:remote_id], user_params)
        rescue RestClient::ExceptionWithResponse => e
          if e.http_code == 409
            action_logger.info "pulp user #{input[:remote_id]}: already exists. continuing"
          else
            raise e
          end
        end
      end
    end
  end
end
