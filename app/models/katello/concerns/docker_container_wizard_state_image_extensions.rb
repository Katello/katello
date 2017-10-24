module Katello
  module Concerns
    module DockerContainerWizardStateImageExtensions
      extend ActiveSupport::Concern

      module Overrides
        def image_exists
          return true if katello?
          super
        end
      end

      included do
        prepend Overrides

        serialize :katello_content, Hash
        validate :katello_content_completed, :if => :katello?
      end

      def katello_content_completed
        empty_values = katello_content.map do |key, value|
          key if value.blank?
        end
        empty_values.compact!

        return true if empty_values.empty?

        message_mapping = {
          organization_id: _("Organization not set"),
          environment_id: _("Lifecycle Environment not set"),
          content_view_id: _("Content View not set"),
          repository_id: _("Repository not set"),
          tag_id: _("Tag not set")
        }
        empty_values.each do |key|
          errors.add(:katello_content, message_mapping[key])
        end
      end
    end
  end
end
