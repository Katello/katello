module Katello
  module Concerns
    module SettingExtensions
      extend ActiveSupport::Concern

      included do
        validates :value, inclusion: { in: ::Katello::RootRepository::DOWNLOAD_POLICIES },
          if: ->(setting) { setting.name == 'default_download_policy' }
        validates_with ::Katello::Validators::ContentDefaultHttpProxySettingValidator,
        if: proc { |s| s.name == 'content_default_http_proxy' && HttpProxy.table_exists? }

        after_save :recalculate_errata_status
        after_save :add_organizations_and_locations_if_global_http_proxy
        after_commit :update_global_proxies
      end

      def recalculate_errata_status
        ForemanTasks.async_task(Actions::Katello::Host::RecalculateErrataStatus) if saved_change_to_attribute?(:value) && name == 'errata_status_installable'
      end

      def update_global_proxies
        if saved_change_to_attribute?(:value) && name == 'content_default_http_proxy'
          repos = ::Katello::Repository.joins(:root).merge(Katello::RootRepository.with_global_proxy).where.not(remote_href: nil).where(library_instance_id: nil)

          unless repos.empty?
            ForemanTasks.async_task(
              ::Actions::BulkAction,
              ::Actions::Katello::Repository::UpdateHttpProxyDetails,
              repos.sort_by(&:pulp_id))
          end
        end
      end

      def add_organizations_and_locations_if_global_http_proxy
        if name == 'content_default_http_proxy' && (::HttpProxy.table_exists? rescue(false))
          proxy = HttpProxy.where(name: value).first

          if proxy
            proxy.update_attribute(:organizations, Organization.unscoped.all)
            proxy.update_attribute(:locations, Location.unscoped.all)
          end
        end
      end
    end
  end
end
