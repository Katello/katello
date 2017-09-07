module Katello
  module Concerns
    module DockerContainerWizardStateImageExtensions
      extend ActiveSupport::Concern

      included do
        alias_method :orig_image_exists, :image_exists
        def image_exists
          orig_image_exists unless katello
        end

        serialize :katello_content, Hash
        validate :katello_content_completed
      end

      def katello_content_completed
        empty_values = katello_content.map do |key, value|
          key if value.blank?
        end
        return true if empty_values.compact.empty?
        error_msg = _("Content View not completelly set")
        errors.add(:katello_content, error_msg)
      end
    end
  end
end
