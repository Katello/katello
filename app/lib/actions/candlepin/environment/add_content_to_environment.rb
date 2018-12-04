module Actions
  module Candlepin
    module Environment
      class AddContentToEnvironment < Candlepin::Abstract
        input_format do
          param :view_env_cp_id
          param :content_id
        end

        def run
          output[:add_response] = ::Katello::Resources::Candlepin::Environment.add_content(input[:view_env_cp_id], [input[:content_id]])
        rescue RestClient::Conflict
          Rails.logger.info("attempted to add content ID #{input[:content_id]} to environment, but content ID already exists.")
        end
      end
    end
  end
end
