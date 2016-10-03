module Katello
  module Concerns
    module SettingExtensions
      extend ActiveSupport::Concern

      included do
        validates :value, inclusion: { in: ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES },
          if: ->(setting) { setting.name == 'default_download_policy' }

        after_save :recalculate_errata_status
      end

      def recalculate_errata_status
        ForemanTasks.async_task(Actions::Katello::Host::RecalculateErrataStatus) if value_changed? && name == 'errata_status_installable'
      end
    end
  end
end
