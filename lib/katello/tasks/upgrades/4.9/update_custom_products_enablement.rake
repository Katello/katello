namespace :katello do
  namespace :upgrades do
    namespace '4.9' do
      desc "Update custom products enablement"
      task :update_custom_products_enablement => ['environment'] do
        include ActionView::Helpers::TextHelper

        print "Creating content overrides for all Candlepin consumers\n"
        consumers_to_update = ::Katello::Resources::Candlepin::Consumer.all_uuids
        # ["Default_Organization_Custom_Custom_Repo", "Default_Organization_TestProd2_TestRepo2"]
        repos_to_update = ::Katello::RootRepository.custom.map(&:custom_content_label) # update all custom repos

        consumers_to_update.each do |consumer_uuid|
          print "Updating consumer #{consumer_uuid}\n"

          # don't overwrite existing overrides
          repos_with_existing_overrides = ::Katello::Resources::Candlepin::Consumer.content_overrides(consumer_uuid).map do |override|
            override[:contentLabel]
          end
          new_overrides = (repos_to_update - repos_with_existing_overrides).map do |repo_label|
            ::Katello::ContentOverride.new(
              repo_label,
              { name: "enabled", value: "1" } # Override to enabled
            )
          end
          ::Katello::Resources::Candlepin::Consumer.update_content_overrides(
            consumer_uuid,
            new_overrides.map(&:to_entitlement_hash)
          )
        rescue => e
          print("Failed to update consumer #{consumer_uuid}: #{e.message}")
        end
        print("Updated #{pluralize(consumers_to_update.count, 'consumer')} and #{pluralize(repos_to_update.count, 'repo')}\n")

        cp_errors = 0
        print "Updating custom products enablement in Candlepin\n"
        ::Katello::ProductContent.custom.each do |product_content|
          ::Katello::Resources::Candlepin::Product.add_content(
            product_content.product.organization.label,
            product_content.product.cp_id,
            product_content.content.cp_content_id,
            ::Actions::Candlepin::Product::ContentAdd::DEFAULT_ENABLEMENT
          )
        rescue => e
          cp_errors + +
          print("Failed to update ProductContent #{product_content.id}: #{e.message}")
        end

        kt_errors = 0
        print "Updating custom products enablement in Katello\n"
        ::Katello::ProductContent.custom.each do |product_content|
          product_content.set_enabled_from_candlepin!
        rescue => e
          kt_errors + +
          print("Failed to update ProductContent #{product_content.id}: #{e.message}")
        end
        total_errors = cp_errors + kt_errors
        print "Finished updating custom products enablement; "
        print(total_errors == 0 ? "no errors\n" : "#{pluralize(total_errors, "error")}\n")
        print("#{pluralize(cp_errors, "error")} updating Candlepin; see log messages above\n") if cp_errors > 0
        print("#{pluralize(kt_errors, "error")} updating Katello; see log messages above\n") if kt_errors > 0
      end
    end
  end
end
