module Katello
  module Concerns
    module SubscriptionFacetHostExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Concerns::ActionTriggering

      included do
        has_one :subscription_facet, :class_name => '::Katello::Host::SubscriptionFacet', :foreign_key => :host_id, :inverse_of => :host, :dependent =>  :destroy
      end

      def update_action
        if self.content_facet && self.content_host && (self.content_host.content_view != self.content_facet.content_view ||
            self.content_host.environment != self.content_facet.lifecycle_environment)
          ::Actions::Katello::Host::Update
        end
      end
    end
  end
end
