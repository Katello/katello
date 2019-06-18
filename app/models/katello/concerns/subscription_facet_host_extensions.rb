module Katello
  module Concerns
    module SubscriptionFacetHostExtensions
      extend ActiveSupport::Concern

      # This module depends on #value_to_sql which is defined in ScopedSearchExtensions
      # make sure this dependency is met.
      include ::ScopedSearchExtensions

      included do
        audited :associations => [:pools]

        SUBSCRIPTION_STATUS_MAP = {
          :valid => Katello::SubscriptionStatus::VALID,
          :partial => Katello::SubscriptionStatus::PARTIAL,
          :invalid => Katello::SubscriptionStatus::INVALID,
          :unknown => Katello::SubscriptionStatus::UNKNOWN,
          :unsubscribed_hypervisor => Katello::SubscriptionStatus::UNSUBSCRIBED_HYPERVISOR
        }.freeze

        prepend ForemanTasks::Concerns::ActionTriggering

        module Prepended
          def update_action
            if subscription_facet.try(:backend_update_needed?)
              ::Actions::Katello::Host::Update
            end
          end
        end

        prepend Prepended

        accepts_nested_attributes_for :subscription_facet, :update_only => true, :reject_if => lambda { |attrs| attrs.values.compact.empty? }

        has_many :activation_keys, :through => :subscription_facet
        has_many :pools, :through => :subscription_facet
        has_many :purpose_addons, :through => :subscription_facet
        has_many :subscriptions, :through => :pools
        has_one :subscription_status_object, :class_name => 'Katello::SubscriptionStatus', :foreign_key => 'host_id', :dependent => :destroy
        has_one :purpose_sla_status_object, :class_name => 'Katello::PurposeSlaStatus', :foreign_key => 'host_id', :dependent => :destroy
        has_one :purpose_role_status_object, :class_name => 'Katello::PurposeRoleStatus', :foreign_key => 'host_id', :dependent => :destroy
        has_one :purpose_usage_status_object, :class_name => 'Katello::PurposeUsageStatus', :foreign_key => 'host_id', :dependent => :destroy
        has_one :purpose_addons_status_object, :class_name => 'Katello::PurposeAddonsStatus', :foreign_key => 'host_id', :dependent => :destroy
        has_one :purpose_status_object, :class_name => 'Katello::PurposeStatus', :foreign_key => 'host_id', :dependent => :destroy
        has_one :hypervisor_host, :through => :subscription_facet

        scoped_search :on => :status, :relation => :subscription_status_object, :rename => :subscription_status,
                      :complete_value => SUBSCRIPTION_STATUS_MAP

        scoped_search on: :status, relation: :purpose_sla_status_object, rename: :sla_status, complete_value: purpose_status_map
        scoped_search on: :status, relation: :purpose_role_status_object, rename: :role_status, complete_value: purpose_status_map
        scoped_search on: :status, relation: :purpose_usage_status_object, rename: :usage_status, complete_value: purpose_status_map
        scoped_search on: :status, relation: :purpose_addons_status_object, rename: :addons_status, complete_value: purpose_status_map
        scoped_search on: :status, relation: :purpose_status_object, rename: :purpose_status, complete_value: purpose_status_map

        scoped_search :on => :release_version, :relation => :subscription_facet, :complete_value => true, :only_explicit => true
        scoped_search :on => :autoheal, :relation => :subscription_facet, :complete_value => true, :only_explicit => true
        scoped_search :on => :service_level, :relation => :subscription_facet, :complete_value => true, :only_explicit => true
        scoped_search :on => :last_checkin, :relation => :subscription_facet, :complete_value => true, :only_explicit => true
        scoped_search :on => :registered_through, :relation => :subscription_facet, :complete_value => true, :only_explicit => true
        scoped_search :on => :registered_at, :relation => :subscription_facet, :rename => :registered_at, :only_explicit => true
        scoped_search :on => :uuid, :relation => :subscription_facet, :rename => :subscription_uuid, :only_explicit => true
        scoped_search :relation => :activation_keys, :on => :name, :rename => :activation_key, :complete_value => true, :ext_method => :find_by_activation_key
        scoped_search :relation => :activation_keys, :on => :id, :rename => :activation_key_id, :complete_value => true, :ext_method => :find_by_activation_key_id,
                      :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
        scoped_search :on => :hypervisor, :relation => :subscription_facet, :complete_value => { :true => true, :false => false }
        scoped_search :on => :name, :relation => :hypervisor_host, :complete_value => true, :rename => :hypervisor_host, :ext_method => :find_by_hypervisor_host
        scoped_search :on => :name, :relation => :subscriptions, :rename => :subscription_name, :complete_value => true, :ext_method => :find_by_subscription_name
        scoped_search :on => :id, :relation => :pools, :rename => :subscription_id, :complete_value => true, :ext_method => :find_by_subscription_id, :only_explicit => true
        scoped_search :on => :purpose_role, :rename => :role, :relation => :subscription_facet, :complete_value => true
        scoped_search :on => :purpose_usage, :rename => :usage, :relation => :subscription_facet, :complete_value => true
        scoped_search :on => :name, :rename => :addon, :relation => :purpose_addons, :complete_value => true, :ext_method => :find_by_purpose_addon
      end

      module ClassMethods
        def purpose_status_map
          ::Katello::PurposeStatus.status_map
        end

        def find_by_purpose_addon(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::PurposeAddon.table_name}.name #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:purpose_addons).where(conditions)
          return_hosts(hosts)
        end

        def find_by_activation_key(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::ActivationKey.table_name}.name #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:activation_keys).where(conditions)
          return_hosts(hosts)
        end

        def find_by_activation_key_id(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::ActivationKey.table_name}.id #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:activation_keys).where(conditions)
          return_hosts(hosts)
        end

        def find_by_hypervisor_host(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{::Host.table_name}.name #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host.where(conditions)
          hosts = ::Host.joins(:subscription_facet).where("#{Katello::Host::SubscriptionFacet.table_name}.hypervisor_host_id" => hosts)
          return_hosts(hosts)
        end

        def find_by_subscription_name(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Subscription.table_name}.name #{operator} ?", value_to_sql(operator, value)])
          sub_facets = ::Katello::Host::SubscriptionFacet.joins(pools: :subscription).where(conditions)
          host_ids = sub_facets.select(:host_id)
          return_hosts_by_id(host_ids)
        end

        def find_by_subscription_id(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Pool.table_name}.id #{operator} ?", value_to_sql(operator, value)])
          sub_facets = ::Katello::Host::SubscriptionFacet.joins(:pools).where(conditions)
          host_ids = sub_facets.select(:host_id)
          return_hosts_by_id(host_ids)
        end

        def return_hosts_by_id(host_ids)
          if host_ids.empty?
            {:conditions => "1=0"}
          else
            {:conditions => "#{::Host::Managed.table_name}.id IN (#{host_ids.to_sql})"}
          end
        end

        def return_hosts(hosts)
          if hosts.empty?
            {:conditions => "1=0"}
          else
            {:conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.pluck(:id).join(',')})"}
          end
        end
      end
    end
  end
end
