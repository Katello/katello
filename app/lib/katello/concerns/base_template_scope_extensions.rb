module Katello
  module Concerns
    module BaseTemplateScopeExtensions
      extend ActiveSupport::Concern

      module Overrides
        def allowed_helpers
          super + [:errata, :host_subscriptions, :host_applicable_errata_ids, :host_applicable_errata_filtered,
                   :host_latest_applicable_rpm_version, :load_pools, :load_errata_applications, :host_content_facet,
                   :host_sla, :host_products, :sub_name, :sub_sku, :registered_through, :last_checkin, :host_collections,
                   :host_subscriptions_names, :host_subscriptions, :host_products_names, :host_collections_names,
                   :host_redhat_subscription_names, :registered_at]
        end
      end

      included do
        prepend Overrides
      end

      def errata(id)
        Katello::Erratum.in_repositories(Katello::Repository.readable).with_identifiers(id).map(&:attributes).first.slice!('created_at', 'updated_at')
      end

      def host_subscriptions(host)
        host.subscriptions
      end

      def host_subscriptions_names(host)
        host.subscriptions.map(&:name)
      end

      def host_redhat_subscription_names(host)
        host.subscriptions.redhat.pluck(:name)
      end

      def host_content_facet(host)
        host.content_facet
      end

      def host_sla(host)
        host_subscription_facet(host)&.service_level
      end

      def host_products(host)
        host_subscription_facet(host)&.installed_products
      end

      def host_products_names(host)
        products = host_products(host)
        if products
          products.map(&:name)
        else
          []
        end
      end

      def host_collections(host)
        host.host_collections
      end

      def host_collections_names(host)
        host.host_collections.map(&:name)
      end

      def sub_name(pool)
        return unless pool
        pool.subscription&.name
      end

      def sub_sku(pool)
        return unless pool
        pool.subscription&.cp_id
      end

      def registered_through(host)
        host_subscription_facet(host)&.registered_through
      end

      def registered_at(host)
        host_subscription_facet(host)&.registered_at
      end

      def host_applicable_errata_ids(host)
        host.applicable_errata.map(&:errata_id)
      end

      def host_applicable_errata_filtered(host, filter = '')
        host.applicable_errata.includes(:cves).search_for(filter)
      end

      def host_latest_applicable_rpm_version(host, package)
        host.applicable_rpms.where(name: package).order(:version_sortable).limit(1).pluck(:nvra).first
      end

      def load_pools(search: '', includes: nil)
        load_resource(klass: Pool.readable, search: search, permission: nil, includes: includes)
      end

      def last_checkin(host)
        host&.subscription_facet&.last_checkin
      end

      # rubocop:disable Metrics/MethodLength
      def load_errata_applications(filter_errata_type: nil, include_last_reboot: 'yes', since: nil, up_to: nil, status: nil)
        result = []

        filter_errata_type = filter_errata_type.presence || 'all'
        search_up_to = up_to.present? ? "ended_at < \"#{up_to}\"" : nil
        search_since = since.present? ? "ended_at > \"#{since}\"" : nil
        search_result = status.present? ? "result = #{status}" : nil
        search = [search_up_to, search_since, search_result].compact.join(' and ')

        if Katello.with_remote_execution?
          condition = ["state != 'stoppped' AND (label = 'Actions::RemoteExecution::RunHostJob' AND templates.id = ?) OR label = 'Actions::Katello::Host::Erratum::Install'", RemoteExecutionFeature.feature('katello_errata_install').job_template_id]
        else
          condition = "state != 'stoppped' AND label = 'Actions::Katello::Host::Erratum::Install'"
        end

        tasks = load_resource(klass: ForemanTasks::Task,
                              where: condition,
                              permission: 'view_foreman_tasks',
                              joins: 'LEFT OUTER JOIN template_invocations ON foreman_tasks_tasks.id = template_invocations.run_host_job_task_id LEFT OUTER JOIN templates ON template_invocations.template_id = templates.id',
                              select: 'foreman_tasks_tasks.*,template_invocations.id AS template_invocation_id',
                              search: search
        )

        # batch of 1_000 records
        tasks.each do |batch|
          @_tasks_errata_cache = {}
          seen_errata_ids = []
          seen_host_ids = []

          batch.each do |task|
            seen_errata_ids = (seen_errata_ids + parse_errata(task)).uniq
            seen_host_ids << task.input['host']['id'] if include_last_reboot == 'yes'
          end

          # preload errata in one query for this batch
          preloaded_errata = Katello::Erratum.where(:errata_id => seen_errata_ids).pluck(:errata_id, :errata_type)
          preloaded_hosts = ::Host.where(:id => seen_host_ids).includes(:reported_data)

          batch.each do |task|
            parse_errata(task).each do |erratum_id|
              current_erratum_errata_type = preloaded_errata.find { |k, _| k == erratum_id }.last

              if filter_errata_type != 'all'
                next unless filter_errata_type == current_erratum_errata_type
              end

              hash = {
                :date => task.ended_at,
                :hostname => task.input['host']['name'],
                :erratum_id => erratum_id,
                :erratum_type => current_erratum_errata_type,
                :status => task.result
              }

              if include_last_reboot == 'yes'
                hash[:last_reboot_time] = preloaded_hosts.find { |k, _| k.id == task.input['host']['id'] }.uptime_seconds&.seconds&.ago
              end

              result << hash
            end
          end
        end

        result
      end
      # rubocop:enable Metrics/MethodLength

      private

      def host_subscription_facet(host)
        host.subscription_facet
      end

      def parse_errata(task)
        @_tasks_errata_cache[task.id] ||= if task.input['errata'].present?
                                            # katello agent errata
                                            task.input['errata']
                                          else
                                            # rex errata
                                            TemplateInvocationInputValue.where(:template_invocation_id => task.template_invocation_id).limit(1).pluck(:value).first.split(',')
                                          end
      end
    end
  end
end
