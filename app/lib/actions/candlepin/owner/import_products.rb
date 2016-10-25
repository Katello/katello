module Actions
  module Candlepin
    module Owner
      class ImportProducts < Candlepin::Abstract
        input_format do
          param :organization_id
        end

        def run
          organization = ::Organization.find(input[:organization_id])
          organization.redhat_provider.import_products_from_cp
        end
      end
    end
  end
end
