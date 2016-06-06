module Katello
  module Concerns
    module SubscriptionFacetHostExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Concerns::ActionTriggering

      included do
        SUBSCRIPTION_STATUS_MAP = {
          :valid => Katello::SubscriptionStatus::VALID,
          :partial => Katello::SubscriptionStatus::PARTIAL,
          :invalid => Katello::SubscriptionStatus::INVALID,
          :unknown => Katello::SubscriptionStatus::UNKNOWN
        }.freeze

        has_one :subscription_facet, :class_name => '::Katello::Host::SubscriptionFacet', :foreign_key => :host_id, :inverse_of => :host, :dependent => :destroy

        has_one :subscription_status_object, :class_name => 'Katello::SubscriptionStatus', :foreign_key => 'host_id'
        scoped_search :on => :status, :in => :subscription_status_object, :rename => :subscription_status,
                      :complete_value => SUBSCRIPTION_STATUS_MAP

        attr_accessible :subscription_facet_attributes

        scoped_search :on => :release_version, :in => :subscription_facet, :complete_value => true
        scoped_search :on => :autoheal, :in => :subscription_facet, :complete_value => true
        scoped_search :on => :service_level, :in => :subscription_facet, :complete_value => true
        scoped_search :on => :last_checkin, :in => :subscription_facet, :complete_value => true
        scoped_search :on => :registered_at, :in => :subscription_facet, :rename => :registered_at
        scoped_search :on => :uuid, :in => :subscription_facet, :rename => :subscription_uuid
      end

      def update_action
        if subscription_facet.try(:backend_update_needed?)
          ::Actions::Katello::Host::Update
        end
      end
    end
  end
end
