module Katello
  module Concerns
    module SettingExtensions
      extend ActiveSupport::Concern

      included do
        validates :value, inclusion: { in: ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES },
          if: ->(setting) { setting.name == 'default_download_policy' }

        after_save :recalculate_errata_status
        after_commit :update_global_proxies
      end

      def recalculate_errata_status
        ForemanTasks.async_task(Actions::Katello::Host::RecalculateErrataStatus) if saved_change_to_attribute?(:value) && name == 'errata_status_installable'
      end

      def update_global_proxies
        if saved_change_to_attribute?(:value) && name == 'content_default_http_proxy'
          repos = RootRepository.with_global_proxy.collect(&:library_instance).uniq

          unless repos.empty?
            ForemanTasks.async_task(
              ::Actions::BulkAction,
              ::Actions::Katello::Repository::UpdateHttpProxyDetails,
              repos.sort_by(&:pulp_id))
          end
        end
      end
    end
  end
end
