namespace :katello do
  namespace :upgrades do
    namespace '4.9' do
      desc "Update custom products enablement"
      task :update_custom_products_enablement => ['environment'] do
        include ActionView::Helpers::TextHelper
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
          cp_errors++
          print("Failed to update ProductContent #{product_content.id}: #{e.message}")
        end

        kt_errors = 0
        print "Updating custom products enablement in Katello\n"
        ::Katello::ProductContent.custom.each do |product_content|
          product_content.set_enabled_from_candlepin!
        rescue => e
          kt_errors++
          print("Failed to update ProductContent #{product_content.id}: #{e.message}")
        end
        total_errors = cp_errors + kt_errors
        print "Finished updating custom products enablement; "
        print(total_errors = 0 ? "no errors\n" : "#{pluralize(total_errors, "error")}\n")
        print("#{pluralize(cp_errors, "error")} updating Candlepin; see log messages above\n") if cp_errors > 0
        print("#{pluralize(kt_errors, "error")} updating Katello; see log messages above\n") if kt_errors > 0
      end
    end
  end
end
