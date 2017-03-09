module Actions
  module Candlepin
    module Consumer
      class UpdateContentOverrides < Candlepin::Abstract
        middleware.use Actions::Middleware::KeepCurrentUser
        input_format do
          param :uuid, String
          param :content_overrides, Array
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.update_content_overrides(input[:uuid], input[:content_overrides])
        end
      end
    end
  end
end
