module Katello
  module Concerns
    module SubscriptionAspectHostExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Concerns::ActionTriggering

      included do
        SUBSCRIPTION_STATUS_MAP = {
          :valid => Katello::SubscriptionStatus::VALID,
          :partial => Katello::SubscriptionStatus::PARTIAL,
          :invalid => Katello::SubscriptionStatus::INVALID,
          :unknown => Katello::SubscriptionStatus::UNKNOWN
        }

        has_one :subscription_aspect, :class_name => '::Katello::Host::SubscriptionAspect', :foreign_key => :host_id, :inverse_of => :host, :dependent =>  :destroy

        has_one :subscription_status_object, :class_name => 'Katello::SubscriptionStatus', :foreign_key => 'host_id'
        scoped_search :on => :status, :in => :subscription_status_object, :rename => :subscription_status,
                      :complete_value => SUBSCRIPTION_STATUS_MAP
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
