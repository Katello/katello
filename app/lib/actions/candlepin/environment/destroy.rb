module Actions
  module Candlepin
    module Environment
      class Destroy < Candlepin::Abstract
        input_format do
          params :cp_id
        end

        def run
          ::Katello::Resources::Candlepin::Environment.destroy(input['cp_id'])
        rescue ::Katello::Errors::CandlepinEnvironmentGone
          Rails.logger.info("Candlepin environment cp_id=#{input['cp_id']} was not found, continuing")
        end
      end
    end
  end
end
