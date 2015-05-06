module Actions
  module Candlepin
    class ActivationKey::Create < Candlepin::Abstract
      input_format do
        param :organization_label
        param :auto_attach
      end

      def run
        output[:response] = ::Katello::Resources::Candlepin::ActivationKey.create(::Katello::Util::Model.uuid,
                                                                                  input[:organization_label],
                                                                                  input[:auto_attach])
      end
    end
  end
end
