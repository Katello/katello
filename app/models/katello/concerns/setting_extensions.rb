module Katello
  module Concerns
    module SettingExtensions
      extend ActiveSupport::Concern

      included do
        validates :value, inclusion: { in: ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES },
          if: ->(setting) { setting.name == 'default_download_policy' }
      end
    end
  end
end
