namespace :katello do
  namespace :upgrades do
    namespace '4.9' do
      desc "Update custom products enablement"
      task :update_custom_products_enablement => ['environment'] do
        include ActionView::Helpers::TextHelper

        ak_errors = create_activation_key_overrides
        consumer_errors = create_consumer_overrides
        cp_errors = update_enablement_in_candlepin
        kt_errors = update_enablement_in_katello

        total_errors = ak_errors + consumer_errors + cp_errors + kt_errors
        print "Finished updating custom products enablement; "
        print(total_errors == 0 ? "no errors\n" : "#{pluralize(total_errors, "error")}\n")
        print("#{pluralize(ak_errors, "error")} updating activation key overrides; see log messages above\n") if ak_errors > 0
        print("#{pluralize(consumer_errors, "error")} updating consumer overrides; see log messages above\n") if consumer_errors > 0
        print("#{pluralize(cp_errors, "error")} updating Candlepin; see log messages above\n") if cp_errors > 0
        print("#{pluralize(kt_errors, "error")} updating Katello; see log messages above\n") if kt_errors > 0
      end

      # rubocop:disable Metrics/MethodLength
      def create_activation_key_overrides
        print "Creating content overrides for all activation keys\n"
        ak_errors = 0
        cp_aks_to_update = ::Katello::Resources::Candlepin::ActivationKey.get.map { |ak| ak['id'] }
        Organization.all.each do |org|
          repos_to_update = ::Katello::RootRepository.custom.in_organization(org).map(&:custom_content_label) # update all custom repos

          org_aks_to_update = ::Katello::ActivationKey.where(organization: org, cp_id: cp_aks_to_update)
          org_aks_to_update.each do |ak|
            print "Updating activation key #{ak.name}\n"
            repos_with_existing_overrides = ::Katello::Resources::Candlepin::ActivationKey.content_overrides(ak.cp_id).map do |override|
              override[:contentLabel]
            end
            new_overrides = (repos_to_update - repos_with_existing_overrides).map do |repo_label|
              ::Katello::ContentOverride.new(
                repo_label,
                { name: "enabled", value: "1" } # Override to enabled
              )
            end
            next if new_overrides.blank?
            ::Katello::Resources::Candlepin::ActivationKey.update_content_overrides(
              ak.cp_id,
              new_overrides.map(&:to_entitlement_hash)
            )
          rescue => e
            ak_errors += 1
            print("Failed to update activation key #{ak.name}: #{e.message}")
          end
        rescue => e
          ak_errors += 1
          print("Error while creating activation key overrides: #{e.message}")
        end
        ak_errors
      end
      # rubocop:enable Metrics/MethodLength

      def create_consumer_overrides
        consumer_errors = 0
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
          next if new_overrides.blank?
          ::Katello::Resources::Candlepin::Consumer.update_content_overrides(
            consumer_uuid,
            new_overrides.map(&:to_entitlement_hash)
          )
        rescue => e
          consumer_errors += 1
          print("Failed to update consumer #{consumer_uuid}: #{e.message}")
        end
        print("Updated #{pluralize(consumers_to_update.count, 'consumer')} and #{pluralize(repos_to_update.count, 'repo')}\n")
        consumer_errors
      end

      def update_enablement_in_candlepin
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
          cp_errors += 1
          print("Failed to update ProductContent #{product_content.id}: #{e.message}")
        end
        cp_errors
      end

      def update_enablement_in_katello
        kt_errors = 0
        print "Updating custom products enablement in Katello\n"
        ::Katello::ProductContent.custom.each do |product_content|
          product_content.set_enabled_from_candlepin!
        rescue => e
          kt_errors += 1
          print("Failed to update ProductContent #{product_content.id}: #{e.message}")
        end
        kt_errors
      end
    end
  end
end
