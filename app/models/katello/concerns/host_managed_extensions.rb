module Katello
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern
      include Katello::KatelloUrlsHelper
      include ForemanTasks::Concerns::ActionSubject

      module Overrides
        def validate_media?
          (content_source_id.blank? || (content_facet && content_facet.kickstart_repository.blank?)) && super
        end

        def smart_proxy_ids
          ids = super
          ids << content_source_id
          ids.uniq.compact
        end
      end

      included do
        prepend Overrides

        has_many :host_installed_packages, :class_name => "::Katello::HostInstalledPackage", :foreign_key => :host_id, :dependent => :delete_all
        has_many :installed_packages, :class_name => "::Katello::InstalledPackage", :through => :host_installed_packages
        has_many :host_traces, :class_name => "::Katello::HostTracer", :foreign_key => :host_id, :dependent => :destroy

        has_many :host_collection_hosts, :class_name => "::Katello::HostCollectionHosts", :foreign_key => :host_id, :dependent => :destroy
        has_many :host_collections, :class_name => "::Katello::HostCollection", :through => :host_collection_hosts

        has_many :hypervisor_pools, :class_name => '::Katello::Pool', :foreign_key => :hypervisor_id, :dependent => :nullify

        before_save :correct_puppet_environment

        scoped_search :relation => :host_collections, :on => :id, :complete_value => false, :rename => :host_collection_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
        scoped_search :relation => :host_collections, :on => :name, :complete_value => true, :rename => :host_collection
        scoped_search :relation => :installed_packages, :on => :nvra, :complete_value => true, :rename => :installed_package, :only_explicit => true
        scoped_search :relation => :installed_packages, :on => :name, :complete_value => true, :rename => :installed_package_name, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :application, :complete_value => true, :rename => :trace_app, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :app_type, :complete_value => true, :rename => :trace_app_type, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :helper, :complete_value => true, :rename => :trace_helper, :only_explicit => true
      end

      def rhsm_organization_label
        self.organization.label
      end

      def self.available_locks
        [:update]
      end

      def correct_puppet_environment
        if content_and_puppet_matched?
          new_environment = content_facet.content_view.puppet_env(content_facet.lifecycle_environment).try(:puppet_environment)
          self.environment = new_environment if new_environment
        end
      end

      def content_and_puppet_matched?
        content_facet && content_facet.content_view_id_was == environment.try(:content_view).try(:id) &&
            content_facet.lifecycle_environment_id_was == self.environment.try(:lifecycle_environment).try(:id)
      end

      def content_and_puppet_match?
        content_facet && content_facet.content_view_id == environment.try(:content_view).try(:id) &&
            content_facet.lifecycle_environment_id == self.environment.try(:lifecycle_environment).try(:id)
      end

      def import_package_profile(simple_packages)
        found = import_package_profile_in_bulk(simple_packages)
        sync_package_associations(found.map(&:id))
      end

      def import_package_profile_in_bulk(simple_packages)
        nvras = simple_packages.map { |sp| sp.nvra }
        found = InstalledPackage.where(:nvra => nvras).select(:id, :nvra).to_a
        found_nvras = found.map(&:nvra)
        new_packages = simple_packages.select { |sp| !found_nvras.include?(sp.nvra) }

        new_packages.each do |simple_package|
          ::Katello::Util::Support.active_record_retry do
            found << InstalledPackage.where(:nvra => simple_package.nvra, :name => simple_package.name).first_or_create!
          end
        end
        found
      end

      def sync_package_associations(new_installed_package_ids)
        old_associated_ids = self.installed_package_ids
        table_name = self.host_installed_packages.table_name

        new_ids = new_installed_package_ids - old_associated_ids
        delete_ids = old_associated_ids - new_installed_package_ids

        queries = []

        if delete_ids.any?
          queries << "DELETE FROM #{table_name} WHERE host_id=#{self.id} AND installed_package_id IN (#{delete_ids.join(', ')})"
        end

        unless new_ids.empty?
          inserts = new_ids.map { |unit_id| "(#{unit_id.to_i}, #{self.id.to_i})" }
          queries << "INSERT INTO #{table_name} (installed_package_id, host_id) VALUES #{inserts.join(', ')}"
        end

        ActiveRecord::Base.transaction do
          queries.each do |query|
            ActiveRecord::Base.connection.execute(query)
          end
        end
      end

      def import_tracer_profile(tracer_profile)
        self.host_traces.destroy_all
        tracer_profile.each do |trace, attributes|
          self.host_traces.create!(:application => trace, :helper => attributes[:helper], :app_type => attributes[:type])
        end
        self.update_trace_status
      end

      def subscription_status
        @subscription_status ||= get_status(::Katello::SubscriptionStatus).status
      end

      def subscription_status_label(options = {})
        @subscription_status_label ||= get_status(::Katello::SubscriptionStatus).to_label(options)
      end

      def subscription_global_status
        @subscription_global_status ||= get_status(::Katello::SubscriptionStatus).to_global
      end

      def errata_status
        @errata_status ||= get_status(::Katello::ErrataStatus).status
      end

      def errata_status_label(options = {})
        @errata_status_label ||= get_status(::Katello::ErrataStatus).to_label(options)
      end

      def valid_content_override_label?(content_label)
        available_content = subscription_facet.candlepin_consumer.available_product_content
        available_content.map(&:content).any? { |content| content.label == content_label }
      end

      protected

      def update_trace_status
        self.get_status(::Katello::TraceStatus).refresh!
        self.refresh_global_status!
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_source, :subscription_manager_configuration_url, :rhsm_organization_label
end
