module Actions
  module Candlepin
    module Owner
      class UpstreamRegenerateCertificates < Candlepin::Abstract
        input_format do
          param :organization_id
          param :upstream
        end

        def run
          organization = ::Organization.find(input[:organization_id])
          output[:response] = organization.redhat_provider.owner_regenerate_upstream_certificates(input[:upstream])
        end
      end
    end
  end
end
