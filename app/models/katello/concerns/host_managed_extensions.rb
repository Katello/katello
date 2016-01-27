module Katello
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern
      include Katello::KatelloUrlsHelper
      include ForemanTasks::Concerns::ActionSubject

      included do
        alias_method_chain :validate_media?, :capsule
        alias_method_chain :set_hostgroup_defaults, :katello_attributes
        alias_method_chain :info, :katello
        alias_method_chain :smart_proxy_ids, :katello

        has_one :content_host, :class_name => "Katello::System", :foreign_key => :host_id,
                               :dependent => :destroy, :inverse_of => :foreman_host
        belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :hosts

        has_many :host_installed_packages, :class_name => "::Katello::HostInstalledPackage", :foreign_key => :host_id, :dependent => :destroy
        has_many :installed_packages, :class_name => "::Katello::InstalledPackage", :through => :host_installed_packages

        has_many :host_collection_hosts, :class_name => "::Katello::HostCollectionHosts", :foreign_key => :host_id, :dependent => :destroy
        has_many :host_collections, :class_name => "::Katello::HostCollection", :through => :host_collection_hosts

        scoped_search :in => :content_source, :on => :name, :complete_value => true, :rename => :content_source
        scoped_search :in => :host_collections, :on => :id, :complete_value => false, :rename => :host_collection_id
        scoped_search :in => :host_collections, :on => :name, :complete_value => true, :rename => :host_collection
      end

      def validate_media_with_capsule?
        content_source_id.blank? && validate_media_without_capsule?
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

      def info_with_katello
        info = info_without_katello
        info['parameters']['kt_env'] = self.lifecycle_environment.try(:label) #deprecated
        info['parameters']['kt_cv'] = self.content_view.try(:label) #deprecated
        info['parameters']['lifecycle_environment'] = self.lifecycle_environment.try(:label)
        info['parameters']['content_view'] = self.content_view.try(:label)
        info
      end

      def content_and_puppet_match?
        content_facet && content_facet.content_view == environment.try(:content_view) &&
            content_facet.lifecycle_environment == self.environment.try(:lifecycle_environment)
      end

      def set_hostgroup_defaults_with_katello_attributes
        if hostgroup.present?
          assign_hostgroup_attributes(%w(content_source_id content_view_id lifecycle_environment_id))
        end
        set_hostgroup_defaults_without_katello_attributes
      end

      def import_package_profile(simple_packages)
        self.installed_packages.where("nvra not in (?)", simple_packages.map(&:nvra)).destroy_all
        existing_nvras = self.installed_packages.pluck(:nvra)
        simple_packages.each do |simple_package|
          self.installed_packages.create!(:name => simple_package.name, :nvra => simple_package.nvra) unless existing_nvras.include?(simple_package.nvra)
        end
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_source, :subscription_manager_configuration_url, :rhsm_organization_label
end
