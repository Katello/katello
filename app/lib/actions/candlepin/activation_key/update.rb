module Actions
  module Candlepin
    module ActivationKey
      class Update < Candlepin::Abstract
        input_format do
          param :cp_id
          param :release_version
          param :service_level
          param :auto_attach
        end

        def run
          ::Katello::Resources::Candlepin::ActivationKey.update(
                                                                input[:cp_id],
                                                                input[:release_version],
                                                                input[:service_level],
                                                                input[:auto_attach])
        end
      end
    end
  end
end
