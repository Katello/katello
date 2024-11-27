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

      apipie :method, 'Returns system purpose SLA for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get system purpose SLA for'
        returns String, example: 'host_purpose_sla(host) #=> "Standard"'
      end
      def host_purpose_sla(host)
        host_subscription_facet(host)&.service_level
      end

      apipie :method, 'Returns system purpose role for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get system purpose role for'
        returns String, example: 'host_purpose_role(host) #=> "Red Hat Enterprise Linux Server"'
      end
      def host_purpose_role(host)
        host_subscription_facet(host)&.purpose_role
      end

      apipie :method, 'Returns system purpose usage for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get system purpose usage for'
        returns String, example: 'host_purpose_usage(host) #=> "Production"'
      end
      def host_purpose_usage(host)
        host_subscription_facet(host)&.purpose_usage
      end

      apipie :method, 'Returns system purpose release version for the host' do
        required :host, 'Host::Managed', desc: 'Host object to get system purpose release version for'
        returns String, example: 'host_purpose_release_version(host) #=> "9"'
      end
      def host_purpose_release_version(host)
        host_subscription_facet(host)&.release_version
      end

      apipie :method, 'Returns whether host is a hypervisor' do
        required :host, 'Host::Managed', desc: 'Host object to determine hypervisor value for'
        returns String, example: 'host_is_hypervisor(host) #=> "t"'
      end
      def host_is_hypervisor(host)
        host_subscription_facet(host)&.hypervisor
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

        new_labels = 'label = Actions::RemoteExecution::RunHostJob AND remote_execution_feature.label ^ (katello_errata_install, katello_errata_install_by_search)'
        labels = [labels, new_labels].map { |label| "(#{label})" }.join(' OR ')
        select += ',template_invocations.id AS template_invocation_id'

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
          preloaded_errata = Katello::Erratum.where(:errata_id => seen_errata_ids).pluck(:errata_id, :errata_type, :issued)
          preloaded_hosts = ::Host.where(:id => seen_host_ids).includes(:reported_data)

          batch.each do |task|
            next if skip_task?(task)
            next unless only_host_ids.nil? || only_host_ids.include?(get_task_input(task)['host']['id'].to_i)
            parse_errata(task).each do |erratum_id|
              current_erratum = preloaded_errata.find { |k, _| k == erratum_id }
              next if current_erratum.nil?
              current_erratum_errata_type = current_erratum[1]
              current_erratum_issued = current_erratum.last

              if filter_errata_type != 'all' && !(filter_errata_type == current_erratum_errata_type)
                next
              end

              hash = {
                :date => task.ended_at,
                :hostname => get_task_input(task)['host']['name'],
                :erratum_id => erratum_id,
                :erratum_type => current_erratum_errata_type,
                :issued => current_erratum_issued,
                :status => task.result,
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

      include Katello::ContentSourceHelper

      apipie :method, "Generate script to change a host's content source" do
        returns String
      end
      def configure_host_for_new_content_source(host, ca_cert)
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
        # agent_input retrieves past katello-agent tasks.
        # There are multiple template inputs, such as errata, pre_script and post_script.
        # We only need the errata input here.
        @_tasks_errata_cache[task.id] ||= agent_input.presence || errata_ids_from_template_invocation(task, task_input)
      end

      def errata_ids_from_template_invocation(task, task_input)
        if task_input.key?('job_features') && task_input['job_features'].include?('katello_errata_install_by_search')
          # This may give wrong results if the template is not rendered yet
          # This also will not work for jobs run before we started storing
          #   resolved ids in the template
          script = task.execution_plan.actions[1].try(:input).try(:[], 'script') || ''
          found = script.lines.find { |line| line.start_with? '# RESOLVED_ERRATA_IDS=' } || ''
          (found.chomp.split('=', 2).last || '').split(',')
        else
          TemplateInvocationInputValue.joins(:template_input).where("template_invocation_id = ? AND template_inputs.name = ?", task.template_invocation_id, 'errata')
            .first&.value&.split(',') || []
        end
      end
    end
  end
end
