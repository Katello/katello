module Actions
  module Candlepin
    class ActivationKey::Create < Candlepin::Abstract
      input_format do
        param :organization_label
        param :auto_attach
        param :purpose_role
        param :purpose_usage
        param :purpse_addons
      end

      def run
        output[:response] = ::Katello::Resources::Candlepin::ActivationKey.create(::Katello::Util::Model.uuid,
                                                                                  input[:organization_label],
                                                                                  input[:auto_attach],
                                                                                  input[:purpose_role],
                                                                                  input[:purpose_usage],
                                                                                  input[:purpose_addons])
      end
    end
  end
end
