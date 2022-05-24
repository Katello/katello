module Katello
  module Concerns
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

      apipie :method, 'Returns subscriptions for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get subscriptions for'
        returns array_of: 'Subscription', desc: 'Array with subscription object'
      end
      def host_subscriptions(host)
        host.subscriptions
      end

      apipie :method, 'Returns subscription names for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get subscriptions for'
        returns array_of: String, desc: "Array with names of host's subscriptions"
      end
      def host_subscriptions_names(host)
        host.subscriptions.map(&:name)
      end

      apipie :method, 'Returns Red Hat subscription names for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get subscriptions for'
        returns array_of: String, desc: "Array with names of host's subscriptions"
      end
      def host_redhat_subscription_names(host)
        host.subscriptions.redhat.pluck(:name)
      end

      apipie :method, 'Returns the count of Red Hat subscriptions consumed for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get subscriptions for'
        returns Integer, desc: "Count of consumed Red Hat subscriptions"
      end
      def host_redhat_subscriptions_consumed(host)
        presenter = ::Katello::HostSubscriptionsPresenter.new(host)
        presenter.subscriptions.select(&:redhat?).sum(&:quantity_consumed)
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
        host.applicable_errata.map(&:errata_id)
      end

      apipie :method, 'Returns filtered applicable errata for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get the applicable errata for'
        optional :filter, String, desc: 'Filter to apply on applicable errata', default: ''
        returns array_of: 'Erratum', desc: 'Filtered applicable errata for the host'
      end
      def host_applicable_errata_filtered(host, filter = '')
        host.applicable_errata.includes(:cves).search_for(filter)
      end

      apipie :method, 'Returns version of the latest applicable RPM package' do
        required :host, 'Host::Managed', desc: 'Host object to get the applicable RPM package version on'
        required :package, String, desc: 'Name of the package'
        returns String, desc: 'Package version'
      end
      def host_latest_applicable_rpm_version(host, package)
        host.applicable_rpms.where(name: package).order(:version_sortable).limit(1).pluck(:nvra).first
      end

      apipie :method, 'Loads Pool objects' do
        desc 'This macro returns a collection of Pools matching search criteria.
          The collection is loaded in bulk, 1000 records at a time.'
        keyword :search, String, desc: 'A search term to limit the resulting collection, using standard search syntax', default: ''
        keyword :includes, Array, of: [String, Symbol], desc: 'An array of associations represented by strings or symbols, to be included in the SQL query. The list can be extended
          from plugins and can not be fully documented here. Most used associations are :subscription, :products, :organization', default: nil
        returns array_of: 'Pool', desc: 'The collection that can be iterated over using each_record'
      end
      def load_pools(search: '', includes: nil)
        load_resource(klass: Pool.readable, search: search, permission: nil, includes: includes)
      end

      apipie :method, 'Returns the last time the host checked in via RHSM' do
        required :host, 'Host::Managed', desc: 'Host object to get the last time the host checked in'
        returns 'ActiveSupport::TimeWithZone', desc: 'The last time the host checked in via RHSM'
      end
      def last_checkin(host)
        host&.subscription_facet&.last_checkin
      end

      apipie :method, 'Load errata applications' do
        desc 'This macro returns a collection of task records relating to errata being applied.
          The collection is loaded in bulk, 1000 records at a time.'
        keyword :filter_errata_type, String, desc: "Errata type. One of: #{Katello::Erratum::TYPES.join(', ')}", default: nil
        keyword :include_last_reboot, String, desc: "Set to 'yes' to include the last reboot time of each host", default: 'yes'
        keyword :since, String, desc: 'Return errata applications after this date'
        keyword :up_to, String, desc: 'Return errata applications before this date'
        keyword :status, String, desc: 'Task status. One of: "pending", "success", "error", "warning"'
        keyword :host_filter, String, desc: 'A filter term to limit the resulting collection, using standard filter syntax', default: nil
        returns array_of: 'Erratum', desc: 'The collection that can be iterated over using each_record'
      end
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def load_errata_applications(filter_errata_type: nil, include_last_reboot: 'yes', since: nil, up_to: nil, status: nil, host_filter: nil)
        result = []

        filter_errata_type = filter_errata_type.presence || 'all'
        search_up_to = up_to.present? ? "ended_at < \"#{up_to}\"" : nil
        search_since = since.present? ? "ended_at > \"#{since}\"" : nil
        search_result = status.present? && status != 'all' ? "result = #{status}" : nil
        labels = 'label ^ (Actions::Katello::Host::Erratum::Install, Actions::Katello::Host::Erratum::ApplicableErrataInstall)'
        select = 'foreman_tasks_tasks.*'

        if Katello.with_remote_execution?
          new_labels = 'label = Actions::RemoteExecution::RunHostJob AND remote_execution_feature.label ^ (katello_errata_install, katello_errata_install_by_search)'
          labels = [labels, new_labels].map { |label| "(#{label})" }.join(' OR ')
          select += ',template_invocations.id AS template_invocation_id'
        else
          select += ',NULL AS template_invocation_id'
        end

        search = [search_up_to, search_since, search_result, "state = stopped", labels].compact.join(' and ')

        tasks = load_resource(klass: ForemanTasks::Task,
                              permission: 'view_foreman_tasks',
                              select: select,
                              search: search)
        only_host_ids = ::Host.search_for(host_filter).pluck(:id) if host_filter

        # batch of 1_000 records
        tasks.each do |batch|
          @_tasks_input = {}
          @_tasks_errata_cache = {}
          seen_errata_ids = []
          seen_host_ids = []

          batch.each do |task|
            next if skip_task?(task)
            seen_errata_ids = (seen_errata_ids + parse_errata(task)).uniq
            seen_host_ids << get_task_input(task)['host']['id'].to_i if include_last_reboot == 'yes'
          end
          seen_host_ids &= only_host_ids if only_host_ids

          # preload errata in one query for this batch
          preloaded_errata = Katello::Erratum.where(:errata_id => seen_errata_ids).pluck(:errata_id, :errata_type)
          preloaded_hosts = ::Host.where(:id => seen_host_ids).includes(:reported_data)

          batch.each do |task|
            next if skip_task?(task)
            next unless only_host_ids.nil? || only_host_ids.include?(task.input['host']['id'].to_i)
            parse_errata(task).each do |erratum_id|
              current_erratum_errata_type = preloaded_errata.find { |k, _| k == erratum_id }.last

              if filter_errata_type != 'all'
                next unless filter_errata_type == current_erratum_errata_type
              end

              hash = {
                :date => task.ended_at,
                :hostname => get_task_input(task)['host']['name'],
                :erratum_id => erratum_id,
                :erratum_type => current_erratum_errata_type,
                :status => task.result
              }

              if include_last_reboot == 'yes'
                # It is possible that we can't find the host if it has been deleted.
                hash[:last_reboot_time] = preloaded_hosts.find { |k, _| k.id == get_task_input(task)['host']['id'].to_i }&.uptime_seconds&.seconds&.ago
              end

              result << hash
            end
          end
        end

        result
      end
      # rubocop:enable Metrics/MethodLength

      apipie :method, 'Converts package version to be sortable' do
        required :version, String, desc: 'Version to convert'
        returns String, desc: 'Sortable version of a package'
        example 'For usage example please refer to **Host - compare content hosts packages** report template'
      end
      def sortable_version(version)
        Util::Package.sortable_version(version)
      end

      apipie :method, 'Returns true if Katello Agent infrastructure is enabled on the server'
      def katello_agent_enabled?
        Katello.with_katello_agent?
      end

      include Katello::ContentSourceHelper

      apipie :method, "Generate script to change a host's content source" do
        returns String
      end
      def change_content_source(host, ca_cert)
        return missing_content_source(host) unless host.content_source

        prepare_ssl_cert(ca_cert) + configure_subman(host.content_source)
      end

      private

      def host_subscription_facet(host)
        host.subscription_facet
      end

      def skip_task?(task)
        # Skip task that doesn't apply errata
        input = get_task_input(task)
        input.blank? || input['host'].blank?
      end

      def get_task_input(task)
        @_tasks_input[task.id] ||= if task.label == 'Actions::Katello::Host::Erratum::ApplicableErrataInstall'
                                     task.execution_plan_action.all_planned_actions(Actions::Katello::Host::Erratum::Install).first.try(:input) || {}
                                   else
                                     task.input
                                   end
      end

      def parse_errata(task)
        task_input = get_task_input(task)
        agent_input = task_input['errata'] || task_input['content']
        # Pick katello agent errata if present
        # Otherwise pick rex errata. There are multiple template inputs, such as errata, pre_script and post_script we only need the
        # errata input here.
        @_tasks_errata_cache[task.id] ||= agent_input.presence || TemplateInvocationInputValue.joins(:template_input)
                                            .where("template_invocation_id = ? AND template_inputs.name = ?", task.template_invocation_id, 'errata')
                                            .first.value.split(',')
      end
    end
  end
end
