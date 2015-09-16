module Katello
  module Concerns
    module SubscriptionAspectHostExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Concerns::ActionTriggering

      included do
        has_one :subscription_aspect, :class_name => '::Katello::Host::SubscriptionAspect', :foreign_key => :host_id, :inverse_of => :host, :dependent =>  :destroy
      end

      def update_action
        if self.content_aspect && (self.content_host.content_view != self.content_aspect.content_view ||
            self.content_host.environment != self.content_aspect.lifecycle_environment)
          ::Actions::Katello::Host::Update
        end
      end
    end
  end
end
