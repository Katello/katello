module Actions
  module Candlepin
    module ActivationKey
      class Update < Candlepin::Abstract
        input_format do
          param :cp_id
          param :release_version
          param :service_level
          param :auto_attach
          param :purpose_role
          param :purpose_usage
        end

        def run
          ::Katello::Resources::Candlepin::ActivationKey.update(
                                                                input[:cp_id],
                                                                input[:release_version],
                                                                input[:service_level],
                                                                input[:auto_attach],
                                                                input[:purpose_role],
                                                                input[:purpose_usage])
        end
      end
    end
  end
end
