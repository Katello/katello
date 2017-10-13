module Katello
  module Glue::Provider
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def sync
        Rails.logger.debug "Syncing provider #{name}"
        syncs = self.products.collect do |p|
          p.sync
        end
        syncs.flatten
      end

      def synced?
        self.products.any? { |p| p.synced? }
      end

      # Get the most relavant status for all the repos in this Provider
      def sync_status
        statuses = self.products.reject { |r| r.empty? }.map { |r| r.sync_status }
        return PulpSyncStatus.new(:state => PulpSyncStatus::Status::NOT_SYNCED) if statuses.empty?

        [PulpSyncStatus::Status::RUNNING,
         PulpSyncStatus::Status::NOT_SYNCED,
         PulpSyncStatus::Status::CANCELED,
         PulpSyncStatus::Status::ERROR].each do |interesting_status|
          relevant_status = statuses.find { |s| s[:state].to_s == interesting_status.to_s }
          return relevant_status if relevant_status
        end

        #else -> all finished
        return statuses[0]
      end

      def sync_state
        self.sync_status[:state]
      end

      def sync_size
        self.products.inject(0) { |sum, v| sum + v.sync_status.progress.total_size }
      end

      def last_sync
        sync_times = []
        self.products.each do |prod|
          break unless prod.respond_to?(:last_sync)
          sync = prod.last_sync
          sync_times << sync unless sync.nil?
        end
        sync_times.sort!
        sync_times.last
      end

      def owner_regenerate_upstream_certificates(upstream)
        if !upstream['idCert'] || !upstream['idCert']['cert'] || !upstream['idCert']['key']
          Rails.logger.error "Upstream identity certificate not available"
          fail _("Upstream identity certificate not available")
        end

        # Default to Red Hat
        url = upstream['apiUrl'] || 'https://subscription.rhn.redhat.com/subscription/consumers/'

        # TODO: wait until ca_path is supported
        #       https://github.com/L2G/rest-client-fork/pull/8
        #ca_file = '/etc/candlepin/certs/upstream/subscription.rhn.stage.redhat.com.crt'
        ca_file = nil

        Resources::Candlepin::UpstreamConsumer.update("#{url}#{upstream['uuid']}/certificates", upstream['idCert']['cert'],
                                                      upstream['idCert']['key'], ca_file, {})
      end

      def owner_upstream_update(upstream, _options)
        if !upstream['idCert'] || !upstream['idCert']['cert'] || !upstream['idCert']['key']
          Rails.logger.error "Upstream identity certificate not available"
          fail _("Upstream identity certificate not available")
        end

        # Default to Red Hat
        url = upstream['apiUrl'] || 'https://subscription.rhn.redhat.com/subscription/consumers/'

        # TODO: wait until ca_path is supported
        #       https://github.com/L2G/rest-client-fork/pull/8
        #ca_file = '/etc/candlepin/certs/upstream/subscription.rhn.stage.redhat.com.crt'
        ca_file = nil

        params = {}
        params[:capabilities] = Resources::Candlepin::CandlepinPing.ping['managerCapabilities'].inject([]) do |result, element|
          result << {'name' => element}
        end
        params[:facts] = {:distributor_version => 'sat-6.3'}
        Resources::Candlepin::UpstreamConsumer.update("#{url}#{upstream['uuid']}", upstream['idCert']['cert'],
                                                      upstream['idCert']['key'], ca_file, params)
      end

      def owner_upstream_export(upstream, zip_file_path, _options)
        if !upstream['idCert'] || !upstream['idCert']['cert'] || !upstream['idCert']['key']
          Rails.logger.error "Upstream identity certificate not available"
          fail _("Upstream identity certificate not available")
        end

        # Default to Red Hat
        url = upstream['apiUrl'] || 'https://subscription.rhn.redhat.com/subscription/consumers/'

        # TODO: wait until ca_path is supported
        #       https://github.com/L2G/rest-client-fork/pull/8
        #ca_file = '/etc/candlepin/certs/upstream/subscription.rhn.stage.redhat.com.crt'
        ca_file = nil

        data = Resources::Candlepin::UpstreamConsumer.export("#{url}#{upstream['uuid']}/export", upstream['idCert']['cert'],
                                                             upstream['idCert']['key'], ca_file)

        File.open(zip_file_path, 'w') do |f|
          f.binmode
          f.write data
        end

        return true
      end

      def del_owner_import
        # This method will delete a manifest that has been imported.  Since it is not possible
        # to delete the changes associated with a specific manifest, we only support deleting
        # the import, if there has only been 1 manifest import completed.  It should be noted
        # that this will destroy all subscriptions associated with the import.
        imports = self.owner_imports
        if imports.length == 1
          Rails.logger.debug "Deleting import for provider: #{name}"
          Resources::Candlepin::Owner.destroy_imports self.organization.label
        else
          Rails.logger.debug "Unable to delete import for provider: #{name}. Reason: a successful import was previously completed."
        end
      end

      def owner_imports
        Resources::Candlepin::Owner.imports self.organization.label
      end

      def import_logger
        ::Foreman::Logging.logger('katello/manifest_import_logger')
      end

      # TODO: break up method
      def import_products_from_cp # rubocop:disable MethodLength
        product_in_katello_ids = self.organization.providers.redhat.first.products.pluck("cp_id")
        products_in_candlepin_ids = []

        marketing_to_engineering_product_ids_mapping.each do |marketing_product_id, engineering_product_ids|
          engineering_product_ids = engineering_product_ids.uniq
          products_in_candlepin_ids << marketing_product_id
          products_in_candlepin_ids.concat(engineering_product_ids)
          added_eng_products = (engineering_product_ids - product_in_katello_ids).map do |id|
            Resources::Candlepin::Product.get(self.organization.label, id)[0]
          end
          adjusted_eng_products = []
          added_eng_products.each do |product_attrs|
            begin
              Glue::Candlepin::Product.import_from_cp(product_attrs) do |p|
                p.provider = self
                p.organization_id = self.organization.id
              end
              adjusted_eng_products << product_attrs
              import_logger.info "import of product '#{product_attrs["name"]}' from Candlepin OK"
            rescue Errors::SecurityViolation => e
              # Do not add non-accessible products
              logger.info "import of product '#{product_attrs["name"]}' from Candlepin failed"
              import_logger.info e
            end
          end

          product_in_katello_ids.concat(adjusted_eng_products.map { |p| p["id"] })

          marketing_product = Katello::Product.find_by_cp_id(marketing_product_id)
          marketing_product.destroy if marketing_product && marketing_product.redhat?
        end

        product_to_remove_ids = (product_in_katello_ids - products_in_candlepin_ids).uniq
        product_to_remove_ids.each do |cp_id|
          product = Product.find_by_cp_id(cp_id, self.organization)
          Rails.logger.warn "Orphaned Product id #{product.id} found while refreshing/importing manifest."
        end

        self.index_subscriptions(self.organization)
        true
      end

      def index_subscriptions(organization = nil)
        Katello::Subscription.import_all(organization)
        Katello::Pool.import_all(organization)
      end

      def rules_source
        redhat_provider? ? candlepin_ping['rulesSource'] : ''
      end

      def rules_version
        redhat_provider? ? candlepin_ping['rulesVersion'] : ''
      end

      protected

      # When a subscription is defined as a virtual data center subscription,
      # its pools will have a seperate 'derived' marketing product and a seperate set
      # of 'derived' engineering products. These products become the marketing and
      # engineering products for the sub pool once a host binds to the original pool.
      # We need to make sure to include these 'derived' products when creating our mapping.
      def marketing_to_engineering_product_ids_mapping
        mapping = {}
        pools = Resources::Candlepin::Owner.pools self.organization.label
        pools.each do |pool|
          mapping[pool[:productId]] ||= []
          if pool[:providedProducts]
            eng_product_ids = pool[:providedProducts].map { |provided| provided[:productId] }
            mapping[pool[:productId]].concat(eng_product_ids)
          end
          # Check to see if there are any 'derived' products defined.
          if pool[:derivedProductId]
            mapping[pool[:derivedProductId]] ||= []
            if pool[:derivedProvidedProducts]
              eng_product_ids = pool[:derivedProvidedProducts].map { |provided| provided[:productId] }
              mapping[pool[:derivedProductId]].concat(eng_product_ids)
            end
          end
        end
        mapping
      end

      def candlepin_ping
        @candlepin_ping ||= Resources::Candlepin::CandlepinPing.ping
      end
    end
  end
end
