module Katello
  module Concerns
    module DockerContainerWizardStateExtensions
      extend ActiveSupport::Concern

      module Overrides
        def container_attributes
          super.merge(:capsule_id => self.image.capsule_id)
        end
      end

      included do
        prepend Overrides
      end
    end
  end
end
