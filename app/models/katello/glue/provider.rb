module Katello
  module Glue::Provider
    DISTRIBUTOR_VERSION = 'sat-6.10'.freeze

    def self.included(base)
      base.send :include, InstanceMethods
    end

    def self.orphaned_custom_product?(cp_id, organization)
      return unless cp_id.present? && orphaned_product?(cp_id, organization)
      product_provider = provider_for_cp_id(cp_id: cp_id, organization: organization)
      if product_provider.redhat_provider?
        false
      else
        Rails.logger.warn "Found orphaned object with id #{cp_id} in Candlepin. Skipping import into Katello; run rake katello:clean_candlepin_orphaned_products to remove it from Candlepin."
        true
      end
    end

    def self.orphaned_product?(cp_id, organization)
      !organization.products.where(:cp_id => cp_id).exists?
    end

    def self.provider_for_cp_id(cp_id:, organization:)
      return organization.redhat_provider unless ::Katello::Glue::Candlepin::Product.engineering_product_id?(cp_id)
      if ::Katello::Glue::Candlepin::Product.custom_product_id?(cp_id)
        organization.anonymous_provider
      else
        organization.redhat_provider
      end
    end

    module InstanceMethods
      API_URL = 'https://subscription.rhsm.redhat.com/subscription/consumers/'.freeze

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

      def owner_upstream_update(upstream, _options)
        if !upstream['idCert'] || !upstream['idCert']['cert'] || !upstream['idCert']['key']
          Rails.logger.error "Upstream identity certificate not available"
          fail _("Upstream identity certificate not available")
        end

        # Default to Red Hat
        url = upstream['apiUrl'] || API_URL

        params = {}
        params[:capabilities] = Resources::Candlepin::CandlepinPing.ping['managerCapabilities'].inject([]) do |result, element|
          result << {'name' => element}
        end
        params[:facts] = {:distributor_version => DISTRIBUTOR_VERSION }
        Resources::Candlepin::UpstreamConsumer.update("#{url}#{upstream['uuid']}", upstream['idCert']['cert'],
                                                      upstream['idCert']['key'], ca_file, params)
      end

      def start_owner_upstream_export(upstream)
        validate_upstream_identity_cert!(upstream)
        url = upstream['apiUrl'] || API_URL

        response = Resources::Candlepin::UpstreamConsumer.get_export("#{url}#{upstream['uuid']}/export/async", upstream['idCert']['cert'],
          upstream['idCert']['key'], ca_file)
        JSON.parse(response)
      end

      def retrieve_owner_upstream_export(upstream, zip_file_path, export_id)
        validate_upstream_identity_cert!(upstream)
        url = upstream['apiUrl'] || API_URL

        data = Resources::Candlepin::UpstreamConsumer.get_export("#{url}#{upstream['uuid']}/export/#{export_id}", upstream['idCert']['cert'],
                                                             upstream['idCert']['key'], ca_file)

        File.write(zip_file_path, data, mode: 'wb')

        true
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

      def import_products_from_cp
        cp_products = ::Katello::Resources::Candlepin::Product.all(organization.label, [:id, :name, :multiplier, :productContent])
        cp_products = cp_products.select { |prod| Glue::Candlepin::Product.engineering_product_id?(prod['id']) }

        prod_content_importer = Katello::ProductContentImporter.new(cp_products)

        Katello::Logging.time("Imported #{cp_products.size} products") do
          cp_products.each do |product_json|
            next if ::Katello::Glue::Provider.orphaned_custom_product?(product_json['id'], organization)
            product = import_product(product_json)
            prod_content_importer.add_product_content(product, product_json['productContent']) if product.redhat?
          end
        end

        Katello::Logging.time("Imported product content") do
          prod_content_importer.import
        end

        self.index_subscriptions
        prod_content_importer
      end

      def import_product(product_json)
        product = organization.products.find_by(:cp_id => product_json['id'])
        if product&.redhat?
          product.update!(:name => product_json['name']) unless product.name == product_json['name']
        elsif product.nil?
          product = Glue::Candlepin::Product.import_redhat_product_from_cp(product_json, organization)
        end
        product
      end

      def index_subscriptions
        Katello::Subscription.import_all(organization)
        Katello::Pool.import_all(organization, false)
      end

      def rules_source
        redhat_provider? ? candlepin_ping['rulesSource'] : ''
      end

      def rules_version
        redhat_provider? ? candlepin_ping['rulesVersion'] : ''
      end

      private

      def validate_upstream_identity_cert!(upstream)
        if !upstream['idCert'] || !upstream['idCert']['cert'] || !upstream['idCert']['key']
          Rails.logger.error "Upstream identity certificate not available"
          fail _("Upstream identity certificate not available")
        end
      end

      def ca_file
        # TODO: wait until ca_path is supported
        #       https://github.com/L2G/rest-client-fork/pull/8
        # ca_file = '/etc/candlepin/certs/upstream/subscription.rhn.stage.redhat.com.crt'
        nil
      end

      protected

      def candlepin_ping
        @candlepin_ping ||= Resources::Candlepin::CandlepinPing.ping
      end
    end
  end
end
