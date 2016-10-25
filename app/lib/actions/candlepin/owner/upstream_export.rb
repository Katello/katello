module Actions
  module Candlepin
    module Owner
      class UpstreamExport < Candlepin::Abstract
        input_format do
          param :organization_id
          param :path
          param :upstream
        end

        def run
          organization = ::Organization.find(input[:organization_id])
          output[:response] = organization.redhat_provider.owner_upstream_export(input[:upstream], input[:path], {})
        end
      end
    end
  end
end
