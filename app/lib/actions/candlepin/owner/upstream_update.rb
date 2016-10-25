module Actions
  module Candlepin
    module Owner
      class UpstreamUpdate < Candlepin::Abstract
        input_format do
          param :organization_id
          param :upstream
        end

        def run
          organization = ::Organization.find(input[:organization_id])
          output[:response] = organization.redhat_provider.owner_upstream_update(input[:upstream], {})
        end
      end
    end
  end
end
