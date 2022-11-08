# like start_upstream_export.rb except for retrieving existing export
# Compare this snippet from app/lib/actions/candlepin/owner/retrieve_upstream_export.rb:
module Actions
  module Candlepin
    module Owner
      class RetrieveUpstreamExport < Candlepin::Abstract
        input_format do
          param :organization_id
          param :path
          param :export_id
        end

        def run
          organization = ::Organization.find(input[:organization_id])
          output[:response] = organization.redhat_provider.retrieve_owner_upstream_export(input[:upstream], input[:path], input[:export_id])
        end
      end
    end
  end
end
