module Actions
  module Candlepin
    class ActivationKey::Destroy < Candlepin::Abstract
      input_format do
        param :cp_id
      end

      def run
        ::Katello::Resources::Candlepin::ActivationKey.destroy(input[:cp_id])
      end
    end
  end
end
