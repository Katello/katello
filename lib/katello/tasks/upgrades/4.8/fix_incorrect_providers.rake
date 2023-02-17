namespace :katello do
  namespace :upgrades do
    namespace '4.8' do
      desc "Fix custom products incorrectly assigned a Red Hat provider"
      task :fix_incorrect_providers => ["dynflow:client", "environment"] do
        User.current = User.anonymous_admin #set a user for orchestration

        print "Fixing incorrect providers\n"
        incorrect_provider_count = 0
        error_msgs = []
        Katello::Product.redhat.includes(:organization).each do |product|
          if ::Katello::Glue::Candlepin::Product.custom_product_id?(product.cp_id)
            print "Fixing provider for #{product.name}\n"
            incorrect_provider_count += 1
            product.provider = product.organization.anonymous_provider
            product.save!
          end
        end

        print "Fixed #{incorrect_provider_count} incorrect providers\n"
        if error_msgs.any?
          print "Errors while fixing providers: #{error_msgs.join("\n")}\n"
        end

        Rake::Task['katello:clean_candlepin_orphaned_products'].invoke
      end
    end
  end
end
