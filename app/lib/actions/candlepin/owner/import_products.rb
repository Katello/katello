module Actions
  module Candlepin
    module Owner
      class ImportProducts < Candlepin::Abstract
        input_format do
          param :organization_id
        end

        def run
          organization = ::Organization.find(input[:organization_id])
          ::Katello::Product.without_auditing do
            User.as_anonymous_admin do
              updated_content = organization.redhat_provider.import_products_from_cp.content_url_updated
              ForemanTasks.async_task(Katello::Repository::UpdateContentUrls, updated_content) if updated_content.present?
            end
          end
        end
      end
    end
  end
end
