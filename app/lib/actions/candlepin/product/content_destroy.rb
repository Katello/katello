module Actions
  module Candlepin
    module Product
      class ContentDestroy < Candlepin::Abstract
        input_format do
          param :content_id
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Content.
              destroy(input[:content_id])
        end
      end
    end
  end
end
