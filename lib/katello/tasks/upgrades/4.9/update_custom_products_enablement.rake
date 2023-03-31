namespace :katello do
  namespace :upgrades do
    namespace '4.9' do
      desc "Update custom products enablement"
      task :update_custom_products_enablement => ["dynflow:client"] do
        ::ForemanTasks.dynflow.initialize!
        User.current = User.anonymous_admin #set a user for orchestration
        print "Updating custom products enablement in Candlepin\n"
        ::Katello::ProductContent.custom.each do |product_content|
          ForemanTasks.sync_task(
            ::Actions::Candlepin::Product::ContentAdd,
            product_id: product_content.product.cp_id,
            content_id: product_content.content.cp_content_id,
            owner: product_content.product.organization.label
          )
        rescue => e
          print "Failed to update ProductContent #{product_content.id}: #{e.message}"
        end

        print "Updating custom products enablement in Katello\n"
        ::Katello::ProductContent.custom.each do |product_content|
          product_content.set_enabled_from_candlepin!
        rescue => e
          print "Failed to update ProductContent #{product_content.id}: #{e.message}"
        end
        print "Finished updating custom products enablement\n"
      end
    end
  end
end
