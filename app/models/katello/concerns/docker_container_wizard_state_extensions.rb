module Katello
  module Concerns
    module DockerContainerWizardStateExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :container_attributes, :katello
      end

      def container_attributes_with_katello
        container_attributes_without_katello.merge(:capsule_id => self.image.capsule_id)
      end
    end
  end
end
