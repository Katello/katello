module Katello
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern
      include Katello::KatelloUrlsHelper
      include ForemanTasks::Concerns::ActionSubject

      included do
        alias_method_chain :validate_media?, :capsule
        alias_method_chain :info, :katello
        alias_method_chain :smart_proxy_ids, :katello

        has_many :host_installed_packages, :class_name => "::Katello::HostInstalledPackage", :foreign_key => :host_id, :dependent => :destroy
        has_many :installed_packages, :class_name => "::Katello::InstalledPackage", :through => :host_installed_packages
        has_many :host_traces, :class_name => "::Katello::HostTracer", :foreign_key => :host_id, :dependent => :destroy

        has_many :host_collection_hosts, :class_name => "::Katello::HostCollectionHosts", :foreign_key => :host_id, :dependent => :destroy
        has_many :host_collections, :class_name => "::Katello::HostCollection", :through => :host_collection_hosts

        before_save :correct_puppet_environment

        scoped_search :relation => :host_collections, :on => :id, :complete_value => false, :rename => :host_collection_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
        scoped_search :relation => :host_collections, :on => :name, :complete_value => true, :rename => :host_collection
        scoped_search :relation => :installed_packages, :on => :nvra, :complete_value => true, :rename => :installed_package, :only_explicit => true
        scoped_search :relation => :installed_packages, :on => :name, :complete_value => true, :rename => :installed_package_name, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :application, :complete_value => true, :rename => :trace_app, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :app_type, :complete_value => true, :rename => :trace_app_type, :only_explicit => true
        scoped_search :relation => :host_traces, :on => :helper, :complete_value => true, :rename => :trace_helper, :only_explicit => true
      end

      def validate_media_with_capsule?
        (content_source_id.blank? || (content_facet && content_facet.kickstart_repository.blank?)) && validate_media_without_capsule?
      end

      def rhsm_organization_label
        self.organization.label
      end

      def self.available_locks
        [:update]
      end

      def smart_proxy_ids_with_katello
        ids = smart_proxy_ids_without_katello
        ids << content_source_id
        ids.uniq.compact
      end

      #rubocop:disable Metrics/AbcSize
      def info_with_katello
        info = info_without_katello
        info['parameters']['kt_env'] = self.lifecycle_environment.try(:label) #deprecated
        info['parameters']['kt_cv'] = self.content_view.try(:label) #deprecated
        info['parameters']['foreman_host_collections'] = self.host_collections.map(&:name)
        info['parameters']['lifecycle_environment'] = self.lifecycle_environment.try(:label)

        info['parameters']['content_view'] = self.content_view.try(:label)
        info['parameters']['content_view_info'] = {}
        info['parameters']['content_view_info']['label'] = self.content_view.try(:label)
        info['parameters']['content_view_info']['latest-version'] = self.content_view.try(:latest_version)
        info['parameters']['content_view_info']['version'] = self.content_view.try(:version, self.lifecycle_environment).try(:version)
        info['parameters']['content_view_info']['published'] = self.content_view.try(:version, self.lifecycle_environment).try(:created_at)
        info['parameters']['content_view_info']['components'] = {}
        if self.content_view.try(:composite)
          self.content_view.try(:version, self.lifecycle_environment).try(:content_view_version_components).each do |cv|
            cv_label = cv.component_version.content_view.label
            info['parameters']['content_view_info']['components'][cv_label] = {}
            info['parameters']['content_view_info']['components'][cv_label]['version'] = cv.component_version.try(:version)
            info['parameters']['content_view_info']['components'][cv_label]['published'] = cv.component_version.try(:created_at)
          end
        end

        if self.content_facet.present?
          info['parameters']['kickstart_repository'] = self.content_facet.kickstart_repository.try(:label)
        end
        info
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
        self.installed_packages.where("nvra not in (?)", simple_packages.map(&:nvra)).destroy_all
        existing_nvras = self.installed_packages.pluck(:nvra)
        simple_packages.each do |simple_package|
          self.installed_packages.create!(:name => simple_package.name, :nvra => simple_package.nvra) unless existing_nvras.include?(simple_package.nvra)
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
