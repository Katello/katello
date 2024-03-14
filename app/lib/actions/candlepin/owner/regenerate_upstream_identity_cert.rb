module Actions
  module Candlepin
    module Owner
      class RegenerateUpstreamIdentityCert < Candlepin::Abstract
        input_format do
          param :organization_id
          param :upstream
        end

        def run
          organization = ::Organization.find(input[:organization_id])
          output[:response] = organization.redhat_provider.owner_upstream_regenerate_identity_cert(input[:upstream])
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
