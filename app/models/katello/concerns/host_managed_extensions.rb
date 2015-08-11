module Katello
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern
      include Katello::KatelloUrlsHelper
      include ForemanTasks::Concerns::ActionSubject

      included do
        before_update :update_content_host, :if => proc { |r| r.lifecycle_environment_id_changed? || r.content_view_id_changed? }

        alias_method_chain :validate_media?, :capsule
        alias_method_chain :set_hostgroup_defaults, :katello_attributes

        has_one :content_host, :class_name => "Katello::System", :foreign_key => :host_id,
                               :dependent => :restrict_with_error, :inverse_of => :foreman_host
        belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :hosts
        belongs_to :content_view, :inverse_of => :hosts, :class_name => "::Katello::ContentView"
        belongs_to :lifecycle_environment, :inverse_of => :hosts, :class_name => "::Katello::KTEnvironment"

        validates_with Katello::Validators::ContentViewEnvironmentValidator

        scoped_search :in => :content_source, :on => :name, :complete_value => true, :rename => :content_source
        scoped_search :in => :content_view, :on => :name, :complete_value => true, :rename => :content_view
        scoped_search :in => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment
      end

      def validate_media_with_capsule?
        content_source_id.blank? && validate_media_without_capsule?
      end

      def rhsm_organization_label
        self.organization.label
      end

      def update_content_host
        if self.content_host && self.lifecycle_environment && self.content_view &&
           ((self.content_host.environment_id != self.lifecycle_environment.id) ||
            (self.content_host.content_view_id != self.content_view.id))
          self.content_host.environment = self.lifecycle_environment
          self.content_host.content_view = self.content_view
          self.content_host.save!
        end
      end

      def content_and_puppet_match?
        self.content_view && self.lifecycle_environment && self.content_view == self.environment.try(:content_view) &&
            self.lifecycle_environment == self.environment.try(:lifecycle_environment)
      end

      def set_hostgroup_defaults_with_katello_attributes
        if hostgroup.present?
          assign_hostgroup_attributes(%w(content_source_id content_view_id lifecycle_environment_id))
        end
        set_hostgroup_defaults_without_katello_attributes
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_source, :subscription_manager_configuration_url, :rhsm_organization_label
end
