module Actions
  module Candlepin
    module Consumer
      class Destroy < Candlepin::Abstract
        input_format do
          param :uuid
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.destroy(input[:uuid])
        rescue RestClient::Gone
          Rails.logger.error(_("Consumer %s has already been removed") % input[:uuid])
        end
      end
    end
  end
end
