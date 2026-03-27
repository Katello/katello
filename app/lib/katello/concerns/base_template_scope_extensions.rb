module Katello
  module Concerns
    # rubocop:disable Metrics/ModuleLength
    module BaseTemplateScopeExtensions
      extend ActiveSupport::Concern
      extend ApipieDSL::Module

      apipie :class, 'Base macros related to content hosts to use within a template' do
        name 'Base Content'
        sections only: %w[all reports provisioning jobs partition_tables]
      end

      apipie :method, 'Returns an erratum by ID' do
        required :id, Integer, desc: 'Errata ID'
        returns Object, desc: 'The erratum object'
      end
      def errata(id)
        Katello::Erratum.in_repositories(Katello::Repository.readable).with_identifiers(id).map(&:attributes).first.slice!('created_at', 'updated_at')
      end

      apipie :method, 'Returns content facet for the host' do
        desc "Content facet is an object containing the host's content-related metadata and associations"
        required :host, 'Host::Managed', desc: 'Host object to get content facet for'
        returns 'ContentFacet'
      end
      def host_content_facet(host)
        host.content_facet
      end

      apipie :method, 'Returns service level for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get service level for'
        returns String, example: 'host_sla(host) #=> "Standard"'
      end
      def host_sla(host)
        host_subscription_facet(host)&.service_level
      end

      apipie :method, 'Returns installed products for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get products for'
        returns array_of: 'Product', desc: "Array of installed product objects on the host"
      end
      def host_products(host)
        host_subscription_facet(host)&.installed_products
      end

      apipie :method, 'Returns installed product names for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get products for'
        returns array_of: String, desc: 'Array with names of installed products on the host'
      end
      def host_products_names(host)
        products = host_products(host)
        if products
          products.map(&:name)
        else
          []
        end
      end

      apipie :method, 'Returns installed product names for the host with CP IDs' do
        required :host, 'Host::Managed', desc: 'Host object to get products for'
        returns array_of: String, desc: 'Array with names and CP IDs of installed products on the host'
      end
      def host_products_names_and_ids(host)
        products = host_products(host)
        if products
          products.collect { |product| "#{product.name} (#{product.cp_product_id})" }
        else
          []
        end
      end

      apipie :method, 'Returns the host collections the host belongs to' do
        required :host, 'Host::Managed', desc: 'Host object to get the host collections for'
        returns array_of: 'HostCollection', desc: "Array of the host collection objects the host belongs to"
      end
      def host_collections(host)
        host.host_collections
      end

      apipie :method, 'Returns names of the host collections the host belongs to' do
        required :host, 'Host::Managed', desc: 'Host object to get the host collections for'
        returns array_of: String, desc: 'Array with names of the host collections the host belongs to'
      end
      def host_collections_names(host)
        host.host_collections.map(&:name)
      end

      apipie :method, 'Returns subscription name of the pool' do
        required :pool, 'Katello::Pool', desc: 'Pool object to get subscription name of'
        returns String, desc: 'Name of the subscription'
      end
      def sub_name(pool)
        return unless pool
        pool.subscription&.name
      end

      apipie :method, 'Returns subscription SKU' do
        required :pool, 'Katello::Pool', desc: 'Pool object to get subscription SKU of'
        returns String, desc: "SKU's ID of the subscription"
      end
      def sub_sku(pool)
        return unless pool
        pool.subscription&.cp_id
      end

      apipie :method, 'Returns the smart proxy that the host was registered through' do
        required :host, 'Host::Managed', desc: 'Host object to get smart proxy of'
        returns String, desc: 'Hostname of the smart proxy'
      end
      def registered_through(host)
        host_subscription_facet(host)&.registered_through
      end

      apipie :method, 'Returns time the host was registered at' do
        required :host, 'Host::Managed', desc: 'Host object to get registration time of'
        returns 'ActiveSupport::TimeWithZone', desc: 'Registration time of the host'
      end
      def registered_at(host)
        host_subscription_facet(host)&.registered_at
      end

      apipie :method, 'Returns IDs of the applicable errata on the host' do
        required :host, 'Host::Managed', desc: 'Host object to get the applicable errata for'
        returns array_of: Integer, desc: 'Array with applicable errata IDs of the host'
      end
      def host_applicable_errata_ids(host)
        host.applicable_errata.pluck(:errata_id)
      end

      apipie :method, 'Returns IDs of the installable errata on the host' do
        required :host, 'Host::Managed', desc: 'Host object to get the installable errata for'
        returns array_of: Integer, desc: 'Array with installable errata IDs of the host'
      end
      def host_installable_errata_ids(host)
        return [] if host.content_facet.nil?
        host.installable_errata.pluck(:errata_id)
      end

      apipie :method, 'Returns filtered applicable errata for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get the applicable errata for'
        optional :filter, String, desc: 'Filter to apply on applicable errata', default: ''
        returns array_of: 'Erratum', desc: 'Filtered applicable errata for the host'
      end
      def host_applicable_errata_filtered(host, filter = '')
        host.applicable_errata.includes(:cves).search_for(filter)
      end

      apipie :method, 'Returns filtered installable errata for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get the installable errata for'
        optional :filter, String, desc: 'Filter to apply on installable errata', default: ''
        returns array_of: 'Erratum', desc: 'Filtered installable errata for the host'
      end
      def host_installable_errata_filtered(host, filter = '')
        return [] if host.content_facet.nil?
        host.installable_errata.includes(:cves).search_for(filter)
      end

      apipie :method, 'Returns version of the latest applicable RPM package' do
        required :host, 'Host::Managed', desc: 'Host object to get the applicable RPM package version on'
        required :package, String, desc: 'Name of the package'
        returns String, desc: 'Package version'
      end
      def host_latest_applicable_rpm_version(host, package)
        return [] if host.content_facet.nil?
        applicable = ::Katello::Rpm.latest(host.applicable_rpms.where(name: package))
        applicable.present? ? applicable.first.nvra : []
      end

      apipie :method, 'Returns version of the latest installable RPM package' do
        required :host, 'Host::Managed', desc: 'Host object to get the installable RPM package version on'
        required :package, String, desc: 'Name of the package'
        returns String, desc: 'Package version'
      end
      def host_latest_installable_rpm_version(host, package)
        return [] if host.content_facet.nil?
        installable = ::Katello::Rpm.latest(host.installable_rpms.where(name: package))
        installable.present? ? installable.first.nvra : []
      end

      apipie :method, 'Loads Pool objects' do
        desc 'This macro returns a collection of Pools matching search criteria.
          The collection is loaded in bulk, 1000 records at a time.'
        keyword :search, String, desc: 'A search term to limit the resulting collection, using standard search syntax', default: ''
        keyword :includes, Array, of: [String, Symbol], desc: 'An array of associations represented by strings or symbols, to be included in the SQL query. The list can be extended
          from plugins and can not be fully documented here. Most used associations are :subscription, :products, :organization', default: nil
        returns array_of: 'Pool', desc: 'The collection that can be iterated over using each_record'
        keyword :expiring_in_days, String, desc: "Return subscriptions expiring in the given number of days. Leave blank to return all subscriptions.", default: nil
      end
      def load_pools(search: '', includes: nil, expiring_in_days: nil)
        pools = Pool.readable
        if expiring_in_days
          pools = pools.expiring_in_days(expiring_in_days)
        end
        load_resource(klass: pools, search: search, permission: nil, includes: includes)
      end

      apipie :method, 'Returns the last time the host checked in via RHSM' do
        required :host, 'Host::Managed', desc: 'Host object to get the last time the host checked in'
        returns 'ActiveSupport::TimeWithZone', desc: 'The last time the host checked in via RHSM'
      end
      def last_checkin(host)
        host&.subscription_facet&.last_checkin
      end

      apipie :method, 'Load errata applications' do
        desc 'This macro returns a collection of errata application records from the database.
          The collection is loaded in bulk, 1000 records at a time.'
        keyword :filter_errata_type, String, desc: "Errata type. One of: #{Katello::Erratum::TYPES.join(', ')}", default: nil
        keyword :include_last_reboot, String, desc: "Set to 'yes' to include the last reboot time of each host", default: 'yes'
        keyword :since, String, desc: 'Return errata applications after this date'
        keyword :up_to, String, desc: 'Return errata applications before this date'
        keyword :status, String, desc: 'Application status. One of: "all", "success", "error", "warning", "cancelled"', default: 'all'
        keyword :host_filter, String, desc: 'A filter term to limit the resulting collection, using standard filter syntax', default: nil
        returns array_of: Hash, desc: 'The collection that can be iterated over using each_record'
      end
      def load_errata_applications(filter_errata_type: nil, include_last_reboot: 'yes', since: nil, up_to: nil, status: 'all', host_filter: nil)
        load_errata_applications_from_db(
          filter_errata_type: filter_errata_type,
          include_last_reboot: include_last_reboot,
          since: since,
          up_to: up_to,
          status: status,
          host_filter: host_filter
        )
      end

      apipie :method, 'Converts package version to be sortable' do
        required :version, String, desc: 'Version to convert'
        returns String, desc: 'Sortable version of a package'
        example 'For usage example please refer to **Host - compare content hosts packages** report template'
      end
      def sortable_version(version)
        Util::Package.sortable_version(version)
      end

      include Katello::ContentSourceHelper

      apipie :method, "Generate script to change a host's content source" do
        returns String
      end
      def configure_host_for_new_content_source(host, ca_cert)
        return missing_content_source(host) unless host.content_source

        prepare_ssl_cert(ca_cert) + configure_subman(host.content_source)
      end

      apipie :method, 'Load errata applications from database' do
        desc 'This macro returns a collection of errata application records from the database.
          This is the new recommended approach that uses dedicated database tracking instead of parsing tasks.'
        keyword :filter_errata_type, String, desc: "Errata type. One of: #{Katello::Erratum::TYPES.join(', ')}", default: nil
        keyword :include_last_reboot, String, desc: "Set to 'yes' to include the last reboot time of each host", default: 'yes'
        keyword :since, String, desc: 'Return errata applications after this date'
        keyword :up_to, String, desc: 'Return errata applications before this date'
        keyword :status, String, desc: 'Application status. One of: "all", "success", "error", "warning", "cancelled"', default: 'all'
        keyword :host_filter, String, desc: 'A filter term to limit the resulting collection, using standard filter syntax', default: nil
        returns array_of: Hash, desc: 'Array of hashes containing errata application data'
      end
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def load_errata_applications_from_db(filter_errata_type: nil, include_last_reboot: 'yes', since: nil, up_to: nil, status: 'all', host_filter: nil)
        result = []

        authorized_hosts = ::Host::Managed.authorized('view_hosts').select(:id)
        applications = Katello::ErrataApplication.where(host_id: authorized_hosts)

        if status.present? && status != 'all'
          return [] if status.to_s.casecmp('pending').zero?
          applications = applications.where(status: status.to_s.downcase)
        end

        if since.present?
          applications = applications.since(Time.zone.parse(since))
        end

        if up_to.present?
          applications = applications.up_to(Time.zone.parse(up_to))
        end

        if host_filter.present?
          applications = applications.where(host_id: ::Host.search_for(host_filter).select(:id))
        end

        # Preload hosts
        if include_last_reboot == 'yes'
          applications = applications.includes(host: :reported_data)
        else
          applications = applications.includes(:host)
        end

        # Fetch host_ids and errata_ids in a single query
        application_data = applications.pluck(:host_id, :errata_ids)
        host_ids = application_data.map(&:first).uniq
        all_errata_ids = application_data.map(&:last).flatten.uniq

        # Preload all errata to avoid N+1 queries
        errata_by_id = Katello::Erratum.where(id: all_errata_ids).index_by(&:id)

        # Fetch applicability only for errata that were applied
        applicable_data = Katello::Host::ContentFacet
          .where(host_id: host_ids)
          .joins(:applicable_errata)
          .where('katello_errata.id' => all_errata_ids)
          .pluck(:host_id, 'katello_errata.id')

        applicable_errata_map =
          applicable_data
            .group_by(&:first)
            .transform_values { |pairs| pairs.map(&:last) }

        # Process each application record
        applications.find_each(batch_size: 1000) do |app|
          # Get applicable erratum IDs for this host (from pre-built map)
          applicable_erratum_ids = applicable_errata_map[app.host_id] || []

          # Create one output row per erratum
          app.errata_ids.each do |erratum_id|
            erratum = errata_by_id[erratum_id]
            next unless erratum

            # Filter by errata type if specified
            next if filter_errata_type.present? && filter_errata_type != 'all' && erratum.errata_type != filter_errata_type

            hash = {
              date: app.applied_at,
              hostname: app.host.name,
              erratum_id: erratum.errata_id,
              erratum_type: erratum.errata_type,
              issued: erratum.issued,
              status: app.status,
              still_applicable: applicable_erratum_ids.include?(erratum.id),
            }

            if include_last_reboot == 'yes'
              hash[:last_reboot_time] = app.host&.uptime_seconds&.seconds&.ago
            end

            result << hash
          end
        end

        result
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      private

      def host_subscription_facet(host)
        host.subscription_facet
      end
    end
  end
end
