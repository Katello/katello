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

        has_many :activation_keys, :through => :subscription_facet
        has_one :subscription_status_object, :class_name => 'Katello::SubscriptionStatus', :foreign_key => 'host_id'
        scoped_search :on => :status, :in => :subscription_status_object, :rename => :subscription_status,
                      :complete_value => SUBSCRIPTION_STATUS_MAP

        scoped_search :on => :release_version, :in => :subscription_facet, :complete_value => true
        scoped_search :on => :autoheal, :in => :subscription_facet, :complete_value => true
        scoped_search :on => :service_level, :in => :subscription_facet, :complete_value => true
        scoped_search :on => :last_checkin, :in => :subscription_facet, :complete_value => true, :only_explicit => true
        scoped_search :on => :registered_through, :in => :subscription_facet, :complete_value => true
        scoped_search :on => :registered_at, :in => :subscription_facet, :rename => :registered_at, :only_explicit => true
        scoped_search :on => :uuid, :in => :subscription_facet, :rename => :subscription_uuid
        scoped_search :in => :activation_keys, :on => :name, :rename => :activation_key, :complete_value => true, :ext_method => :find_by_activation_key
        scoped_search :in => :activation_keys, :on => :id, :rename => :activation_key_id, :complete_value => true, :ext_method => :find_by_activation_key_id, :only_explicit => true
      end

      def update_action
        if subscription_facet.try(:backend_update_needed?)
          ::Actions::Katello::Host::Update
        end
      end

      module ClassMethods
        def find_by_activation_key(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::ActivationKey.table_name}.name #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:activation_keys).where(conditions)
          if hosts.empty?
            { :conditions => "1=0" }
          else
            { :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.pluck(:id).join(',')})" }
          end
        end

        def find_by_activation_key_id(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::ActivationKey.table_name}.id #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:activation_keys).where(conditions)
          if hosts.empty?
            { :conditions => "1=0" }
          else
            { :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.pluck(:id).join(',')})" }
          end
        end
      end
    end
  end
end
