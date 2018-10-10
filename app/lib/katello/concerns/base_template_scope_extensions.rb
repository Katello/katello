module Katello
  module Concerns
    module BaseTemplateScopeExtensions
      extend ActiveSupport::Concern

      module Overrides
        def allowed_helpers
          super + [:errata, :host_subscriptions, :host_applicable_errata_ids, :host_applicable_errata_filtered,
                   :host_latest_applicable_rpm_version, :load_pools]
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

      def host_applicable_errata_ids(host)
        host.applicable_errata.map(&:errata_id)
      end

      def host_applicable_errata_filtered(host, filter = '')
        host.applicable_errata.search_for(filter)
      end

      def host_latest_applicable_rpm_version(host, package)
        host.applicable_rpms.where(name: package).order(:version_sortable).limit(1).pluck(:nvra).first
      end

      def load_pools(search: '', includes: nil)
        load_resource(klass: Pool.readable, search: search, permission: nil, includes: includes)
      end
    end
  end
end
