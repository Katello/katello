module Katello
  module Glue::Provider
    def self.included(base)
      base.send :include, InstanceMethods
      base.class_eval do
        before_destroy :destroy_products_orchestration
      end
    end

    module InstanceMethods
      def import_manifest(zip_file_path, options = {})
        options = {:zip_file_path => zip_file_path}.merge(options)
        options.assert_valid_keys(:force, :zip_file_path)

        queue_import_manifest options
      end

      def delete_manifest
        queue_delete_manifest
      end

      def refresh_manifest(upstream, options = {})
        options = { :upstream => upstream }.merge(options)
        options.assert_valid_keys(:upstream)

        queue_import_manifest(options)
      end

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

      #get last sync status of all repositories in this provider
      def latest_sync_statuses
        statuses = self.products.collect do |p|
          p.latest_sync_statuses
        end
        statuses.flatten
      end

      # Get the most relavant status for all the repos in this Provider
      def sync_status
        statuses = self.products.reject { |r| r.empty? }.map { |r| r.sync_status }
        return PulpSyncStatus.new(:state => PulpSyncStatus::Status::NOT_SYNCED) if statuses.empty?

        [PulpSyncStatus::Status::RUNNING,
         PulpSyncStatus::Status::NOT_SYNCED,
         PulpSyncStatus::Status::CANCELED,
         PulpSyncStatus::Status::ERROR].each do |interesting_status|
          relevant_status =  statuses.find { |s| s[:state].to_s == interesting_status.to_s }
          return relevant_status if relevant_status
        end

        #else -> all finished
        return statuses[0]
      end

      def sync_state
        self.sync_status[:state]
      end

      def sync_start
        start_times = []
        self.products.each do |prod|
          start = prod.sync_start
          start_times << start unless start.nil?
        end
        start_times.sort!
        start_times.last
      end

      def sync_finish
        finish_times = []
        self.products.each do |r|
          finish = r.sync_finish
          finish_times << finish unless finish.nil?
        end
        finish_times.sort!
        finish_times.last
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

      def url_to_host_and_path(url = "")
        parsed = URI.parse(url)
        ["#{parsed.scheme}://#{parsed.host}#{ parsed.port ? ':' + parsed.port.to_s : '' }", parsed.path]
      end

      def del_products
        Rails.logger.debug "Deleting all products for provider: #{name}"
        self.products.uniq.each(&:destroy)
        true
      rescue => e
        Rails.logger.error "Failed to delete all products for provider #{name}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def owner_import(zip_file_path, options)
        Resources::Candlepin::Owner.import self.organization.label, zip_file_path, options
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

        capabilities = Resources::Candlepin::CandlepinPing.ping['managerCapabilities'].inject([]) do |result, element|
          result << {'name' => element}
        end
        Resources::Candlepin::UpstreamConsumer.update("#{url}#{upstream['uuid']}", upstream['idCert']['cert'],
                                                      upstream['idCert']['key'], ca_file, :capabilities => capabilities)
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
      def queue_import_manifest(options)
        options = options.with_indifferent_access
        fail "zip_file_path or upstream must be specified" if options[:zip_file_path].nil? && options[:upstream].nil?

        #if a manifest has already been imported, we need to update the products
        manifest_update = self.products.any?
        #are we refreshing from upstream?
        manifest_refresh = options['zip_file_path'].nil?

        import_logger.debug "Importing manifest for provider #{self.name}"

        begin
          if manifest_refresh
            zip_file_path = "/tmp/#{rand}.zip"
            upstream = options[:upstream]
            pre_queue.create(:name => "export upstream manifest for owner: #{self.organization.name}",
                             :priority => 2, :action => [self, :owner_upstream_update, upstream, options],
                             :action_rollback => nil)
            pre_queue.create(:name => "export upstream manifest for owner: #{self.organization.name}",
                             :priority => 3, :action => [self, :owner_upstream_export, upstream, zip_file_path, options],
                             :action_rollback => nil)
          else
            zip_file_path = options[:zip_file_path]
          end

          pre_queue.create(:name     => "import manifest #{zip_file_path} for owner: #{self.organization.name}",
                           :priority => 4, :action => [self, :owner_import, zip_file_path, options],
                           :action_rollback => [self, :del_owner_import])
          pre_queue.create(:name     => "import of products in manifest #{zip_file_path}",
                           :priority => 5, :action => [self, :import_products_from_cp])
          pre_queue.create(:name     => "refresh product repos",
                           :priority => 6, :action => [self, :refresh_existing_products]) if manifest_update && SETTINGS[:katello][:use_pulp]

          self.save!
        rescue => error
          display_manifest_message(manifest_refresh ? 'refresh' : 'import', error)
          raise error
        end
      end

      def refresh_existing_products
        self.products.each { |p| p.update_repositories }
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
            Resources::Candlepin::Product.get(id)[0]
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

        self.index_subscriptions
        true
      end

      def destroy_products_orchestration
        pre_queue.create(:name => "delete products for provider: #{self.name}", :priority => 1, :action => [self, :del_products])
      end

      def import_error_message(display_message)
        error_texts = [
          _("Subscription manifest upload for provider '%s' failed.") % self.name,
          (_("Reason: %s") % display_message unless display_message.blank?)
        ].compact
        error_texts.join('<br />')
      end

      def refresh_error_message(display_message)
        error_texts = [
          _("Subscription manifest refresh for provider '%s' failed.") % self.name,
          (_("Reason: %s") % display_message unless display_message.blank?)
        ].compact
        error_texts.join('<br />')
      end

      def exec_delete_manifest
        Resources::Candlepin::Owner.destroy_imports self.organization.label, true
        index_subscriptions
      end

      def index_subscriptions
        Katello::Subscription.import_all
        Katello::Pool.import_all
      end

      def rollback_delete_manifest
        # Nothing to be done until implemented in katello where possible pulp recovery actions should be done(?)
      end

      def queue_delete_manifest
        import_logger.debug "Deleting manifest for provider #{self.name}"

        begin
          pre_queue.create(:name     => "delete manifest for owner: #{self.organization.name}",
                           :priority => 3, :action => [self, :exec_delete_manifest],
                           :action_rollback => [self, :rollback_delete_manifest])
          if SETTINGS[:katello][:use_pulp]
            pre_queue.create(:name => "refresh product repos for deletion",
                             :priority => 6, :action => [self, :refresh_existing_products])
          end
          self.save!
        rescue => error
          display_manifest_message('delete', error)
          raise error
        end
      end

      def rules_source
        redhat_provider? ? candlepin_ping['rulesSource'] : ''
      end

      def rules_version
        redhat_provider? ? candlepin_ping['rulesVersion'] : ''
      end

      protected

      # Display appropriate messages when manifest import or delete fails
      # TODO: break up this method
      def display_manifest_message(type, error)
        # Clean up response from candlepin
        types = {'import' => _('import'), 'delete' => _('delete'), 'refresh' => _('refresh')} # For i18n
        begin
          if error.respond_to?(:response)
            results = JSON.parse(error.response)
          elsif error.message
            results = {'displayMessage' => error.message, 'conflicts' => ['UNKNOWN']}
          else
            results = {'displayMessage' => _('Manifest %s failed') % types[type], 'conflicts' => ['UNKNOWN']}
          end
        rescue
          results = {'displayMessage' => _('Manifest %s failed') % types[type], 'conflicts' => []}
        end

        Rails.logger.error "Error during manifest #{type}: #{results}"
      end

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
