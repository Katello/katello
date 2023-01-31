namespace :katello do
  desc "Removes custom products (and their associated pools and subscriptions) from Candlepin that are not in Katello"
  task :clean_candlepin_orphaned_products => ["dynflow:client", "environment"] do
    User.current = User.anonymous_admin #set a user for orchestration

    deleted_products_counts = {}
    Organization.all.each do |org|
      print "Cleaning Candlepin orphaned custom products for organization #{org.name}\n"

      cp_products = Katello::Resources::Candlepin::Product.all(org.label)
      cp_products = cp_products.select { |prod| Katello::Glue::Candlepin::Product.engineering_product_id?(prod['id']) }
      cp_product_ids = cp_products.map { |cp_product| cp_product['id'] }

      katello_product_ids = Katello::Product.where(:organization_id => org.id).pluck(:cp_id)
      orphaned_cp_product_ids = cp_product_ids - katello_product_ids
      orphaned_cp_product_ids.each do |cp_product_id|
        print "Deleting Candlepin orphaned custom product #{cp_product_id} (and its associated pools and subscriptions)\n"
        ForemanTasks.sync_task(
          ::Actions::Candlepin::Product::DeletePools,
          cp_id: cp_product_id, organization_label: org.label)

        ForemanTasks.sync_task(
          ::Actions::Candlepin::Product::DeleteSubscriptions,
          cp_id: cp_product_id, organization_label: org.label)

        ForemanTasks.sync_task(
          ::Actions::Candlepin::Product::Destroy,
          owner: org.label, cp_id: cp_product_id)
      end

      deleted_products_counts[org.name] = orphaned_cp_product_ids.length
    end

    deleted_products_counts.each do |org_name, deleted_products_count|
      print "Deleted #{deleted_products_count} Candlepin orphaned custom products for organization #{org_name}\n"
    end
  end
end
