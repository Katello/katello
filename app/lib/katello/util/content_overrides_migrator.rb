module Katello
  module Util
    class ContentOverridesMigrator # used in Actions::Katello::Organization::SimpleContentAccess::PrepareContentOverrides
      include ActionView::Helpers::TextHelper

      def initialize(organization:)
        @organization = organization
      end

      def execute_non_sca_overrides!
        host_errors = create_disabled_overrides_for_non_sca_org_hosts(organization: @organization)
        ak_errors = create_disabled_overrides_for_non_sca_org_activation_keys(organization: @organization)

        total_errors = host_errors + ak_errors
        finish_message = "Finished creating overrides in non-SCA org; #{total_errors == 0 ? "no errors" : "#{pluralize(total_errors, "error")}"}"
        messages = { result: finish_message, errors: total_errors }
        messages[:host_errors] = "Hosts - #{pluralize(host_errors, "error")} creating disabled overrides for unsubscribed content; see log messages above" if host_errors > 0
        messages[:ak_errors] = "Activation keys - #{pluralize(ak_errors, "error")} creating disabled overrides for unsubscribed content; see log messages above" if ak_errors > 0
        messages[:success_message] = "Organization may now be switched to Simple Content Access mode without any change in access to content." if total_errors == 0
        Rails.logger.info finish_message
        Rails.logger.info messages[:host_errors] if messages[:host_errors]
        Rails.logger.info messages[:ak_errors] if messages[:ak_errors]
        Rails.logger.info messages[:success_message] if messages[:success_message]
        messages
      end

      def create_disabled_overrides_for_non_sca(consumable:)
        content_finder = ::Katello::ProductContentFinder.new(
                match_subscription: false,
                match_environment: false,
                consumable: consumable
              )
        subscribed_content_finder = ::Katello::ProductContentFinder.new(
          match_subscription: true,
          match_environment: false,
          consumable: consumable
        )
        candlepin_resource = consumable.is_a?(::Katello::Host::SubscriptionFacet) ? ::Katello::Resources::Candlepin::Consumer : ::Katello::Resources::Candlepin::ActivationKey
        consumable_id = consumable.is_a?(::Katello::Host::SubscriptionFacet) ? consumable.uuid : consumable.cp_id
        repos_with_existing_overrides = candlepin_resource.content_overrides(consumable_id).map do |override|
          override[:contentLabel]
        end
        unsubscribed_content = content_finder.custom_content_labels - subscribed_content_finder.custom_content_labels - repos_with_existing_overrides
        new_overrides = unsubscribed_content.map do |repo_label|
          ::Katello::ContentOverride.new(
            repo_label,
            { name: "enabled", value: "0" } # Override to disabled
          )
        end
        return if new_overrides.blank?
        if consumable.is_a? ::Katello::Host::SubscriptionFacet
          ::Katello::Resources::Candlepin::Consumer.update_content_overrides(
            consumable.uuid,
            new_overrides.map(&:to_entitlement_hash)
          )
        else
          ::Katello::Resources::Candlepin::ActivationKey.update_content_overrides(
            consumable.cp_id,
            new_overrides.map(&:to_entitlement_hash)
          )
        end
      end

      def create_disabled_overrides_for_non_sca_org_hosts(organization:)
        errors = 0
        fail _("Organization must be specified") if organization.blank?
        return 0 if organization.simple_content_access? # subscription attachment is meaningless with SCA
        Rails.logger.info("Hosts - Creating disabled overrides for unsubscribed content in organization #{organization.name}")
        # only registered hosts with content!
        hosts_to_update = organization.hosts.joins(:subscription_facet).where.not("#{Katello::Host::SubscriptionFacet.table_name}.host_id" => nil)
        hosts_to_update.each do |host|
          create_disabled_overrides_for_non_sca(consumable: host.subscription_facet)
        rescue => e
          errors += 1
          Rails.logger.error("Failed to update host #{host.name}: #{e.message}")
          Rails.logger.debug e.backtrace.join("\n")
        end
        errors
      end

      def create_disabled_overrides_for_non_sca_org_activation_keys(organization:)
        errors = 0
        fail _("Organization must be specified") if organization.blank?
        return 0 if organization.simple_content_access? # subscription attachment is meaningless with SCA
        Rails.logger.info("Activation keys - Creating disabled overrides for unsubscribed content in organization #{organization.name}")
        aks_to_update = organization.activation_keys
        aks_to_update.each do |ak|
          create_disabled_overrides_for_non_sca(consumable: ak)
        rescue => e
          errors += 1
          Rails.logger.error("Failed to update activation key #{ak.name}: #{e.message}")
          Rails.logger.debug e.backtrace.join("\n")
        end
        errors
      end
    end
  end
end
