module Katello
  module Concerns
    module HostgroupExtensions
      extend ActiveSupport::Concern

      included do
        before_save :add_organization_for_environment
        belongs_to :kickstart_repository, :class_name => "::Katello::Repository", :foreign_key => :kickstart_repository_id
        belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :hostgroups
        belongs_to :content_view, :inverse_of => :hostgroups, :class_name => "::Katello::ContentView"
        belongs_to :lifecycle_environment, :inverse_of => :hostgroups, :class_name => "::Katello::KTEnvironment"

        validates_with Katello::Validators::ContentViewEnvironmentValidator

        attr_accessible :content_view_id, :lifecycle_environment_id, :content_source_id, :kickstart_repository_id

        scoped_search :in => :content_source, :on => :name, :complete_value => true, :rename => :content_source
        scoped_search :in => :content_view, :on => :name, :complete_value => true, :rename => :content_view
        scoped_search :in => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment
      end

      def content_view
        return super if ancestry.nil? || self.content_view_id.present?
        Katello::ContentView.find_by(:id => inherited_content_view_id)
      end

      def lifecycle_environment
        return super if ancestry.nil? || self.lifecycle_environment_id.present?
        Katello::KTEnvironment.find_by(:id => inherited_lifecycle_environment_id)
      end

      # instead of calling nested_attribute_for(:content_source_id) in Foreman, define the methods explictedly
      def content_source
        return super if ancestry.nil? || self.content_source_id.present?
        SmartProxy.find_by(:id => inherited_content_source_id)
      end

      def inherited_content_source_id
        inherited_ancestry_attribute(:content_source_id)
      end

      def inherited_content_view_id
        inherited_ancestry_attribute(:content_view_id)
      end

      def inherited_lifecycle_environment_id
        inherited_ancestry_attribute(:lifecycle_environment_id)
      end

      def inherited_kickstart_repository_id
        inherited_ancestry_attribute(:kickstart_repository_id)
      end

      def rhsm_organization_label
        #used for rhsm registration snippet, since hostgroup can belong to muliple organizations, use lifecycle environment or cv
        (self.lifecycle_environment || self.content_view).try(:organization).try(:label)
      end

      def add_organization_for_environment
        #ensures that the group's orgs include whatever lifecycle environment is assigned
        if self.lifecycle_environment && !self.organizations.include?(self.lifecycle_environment.organization)
          self.organizations << self.lifecycle_environment.organization
        end
      end

      def content_and_puppet_match?
        self.content_view && self.lifecycle_environment && self.content_view == self.environment.try(:content_view) &&
            self.lifecycle_environment == self.environment.try(:lifecycle_environment)
      end

      private

      def inherited_ancestry_attribute(attribute)
        if ancestry.present?
          self[attribute] || self.class.sort_by_ancestry(ancestors.where("#{attribute.to_s} is not NULL")).last.try(attribute)
        else
          self.send(attribute)
        end
      end
    end
  end
end

class ::Hostgroup::Jail < Safemode::Jail
  allow :content_source, :rhsm_organization_label, :subscription_manager_configuration_url
end
