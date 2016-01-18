module Actions
  module Candlepin
    module Consumer
      class AutoAttachSubscriptions < Candlepin::Abstract
        input_format do
          param :uuid, String
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.refresh_entitlements(input[:uuid])
        end
      end
    end
  end
end
