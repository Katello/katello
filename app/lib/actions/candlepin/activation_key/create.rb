module Actions
  module Candlepin
    class ActivationKey::Create < Candlepin::Abstract
      input_format do
        param :organization_label
        param :auto_attach
        param :service_level
        param :release_version
        param :purpose_role
        param :purpose_usage
      end

      def run
        output[:response] = ::Katello::Resources::Candlepin::ActivationKey.create(::Katello::Util::Model.uuid,
                                                                                  input[:organization_label],
                                                                                  input[:auto_attach],
                                                                                  input[:service_level],
                                                                                  input[:release_version],
                                                                                  input[:purpose_role],
                                                                                  input[:purpose_usage])
      end
    end
  end
end
