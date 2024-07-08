module Katello
  module Concerns
    module HostgroupExtensions
      extend ActiveSupport::Concern

      included do
        before_save :add_organization_for_environment

        has_one :kickstart_repository, :through => :content_facet
        has_one :content_source, :through => :content_facet
        has_one :content_view, :through => :content_facet
        has_one :lifecycle_environment, :through => :content_facet

        scoped_search :relation => :content_source, :on => :name, :complete_value => true, :rename => :content_source, :only_explicit => true
        scoped_search :relation => :content_view, :on => :name, :complete_value => true, :rename => :content_view, :only_explicit => true
        scoped_search :relation => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment, :only_explicit => true

        before_validation :correct_kickstart_repository

        delegate :content_source_name, :content_view_name, :lifecycle_environment_name, to: :content_facet, allow_nil: true
        delegate :content_source_id, :content_view_id, :lifecycle_environment_id, :kickstart_repository_id, to: :content_facet, allow_nil: true
        delegate :'content_source_id=', :'content_view_id=', :'lifecycle_environment_id=', :'kickstart_repository_id=', to: :safe_content_facet, allow_nil: true

        apipie :class do
          property :content_source, 'SmartProxy', desc: 'Returns Smart Proxy object as the content source for the host group'
          property :subscription_manager_configuration_url, String, desc: 'Returns URL for subscription manager configuration'
          property :rhsm_organization_label, String, desc: 'Returns label of the Red Hat Subscription Manager organization'
        end
      end

      def correct_kickstart_repository
        # If switched from ks repo to install media:
        if medium_id_changed? && medium && content_facet&.kickstart_repository_id
          # since it's :through association, nullify both the actual data source and delegate
          self.content_facet.kickstart_repository = nil
          self.kickstart_repository = nil
        # If switched from install media to ks repo:
        elsif content_facet&.kickstart_repository && medium
          self.medium = nil
        end

        if content_facet&.kickstart_repository_id && !matching_kickstart_repository?(content_facet) && (equivalent = equivalent_kickstart_repository)
          self.content_facet.kickstart_repository_id = equivalent[:id]
        end
      end

      def content_view
        return super if ancestry.nil? || self.content_view_id.present?
        Katello::ContentView.find_by(:id => inherited_content_view_id)
      end

      def lifecycle_environment
        return super if ancestry.nil? || self.lifecycle_environment_id.present?
        Katello::KTEnvironment.find_by(:id => inherited_lifecycle_environment_id)
      end

      def kickstart_repository
        return super if ancestry.nil? || self.kickstart_repository_id.present?
        Katello::Repository.find_by(:id => inherited_kickstart_repository_id)
      end

      # instead of calling nested_attribute_for(:content_source_id) in Foreman, define the methods explictedly
      def content_source
        return super if ancestry.nil? || self.content_source_id.present?
        SmartProxy.unscoped.find_by(:id => inherited_content_source_id)
      end

      def inherited_content_source_id
        inherited_ancestry_attribute(:content_source_id, :content_facet)
      end

      def inherited_content_view_id
        inherited_ancestry_attribute(:content_view_id, :content_facet)
      end

      def inherited_lifecycle_environment_id
        inherited_ancestry_attribute(:lifecycle_environment_id, :content_facet)
      end

      def inherited_kickstart_repository_id
        inherited_ancestry_attribute(:kickstart_repository_id, :content_facet)
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

      def equivalent_kickstart_repository
        return unless operatingsystem &&
                      content_facet.kickstart_repository &&
                      operatingsystem.respond_to?(:kickstart_repos)
        ks_repos = operatingsystem.kickstart_repos(self, content_facet: content_facet)
        ks_repos.find { |repo| repo[:name] == content_facet.kickstart_repository.label }
      end

      def matching_kickstart_repository?(content_facet)
        return true unless operatingsystem

        if operatingsystem.respond_to? :kickstart_repos
          operatingsystem.kickstart_repos(self, content_facet: content_facet).any? do |repo|
            repo[:id] == (content_facet&.kickstart_repository_id || content_facet&.kickstart_repository&.id)
          end
        end
      end

      private

      def inherited_ancestry_attribute(attribute, facet)
        value = self.send(facet)&.send(attribute)

        if value.nil? && ancestry.present?
          # take first non-null value for the attribute going up the ancestry tree.
          # example: you have hg1 -> hg11 -> hg111 -> hg1111 hostgroups.
          # given we are querying hg1111 (the leaf), and a value is set on:
          # hg1: 1
          # hg11: 2
          # it will return the value 2.
          facet_model = Facets.registered_facets[facet].hostgroup_configuration.model
          value = facet_model.where.not(attribute => nil).joins(:hostgroup).merge(
            ::Hostgroup.where(id: self.ancestor_ids).reorder(
              "#{::Hostgroup.table_name}.ancestry desc nulls last"
            )
          ).pick(attribute)
        end
        value
      end

      def safe_content_facet
        content_facet || build_content_facet
      end
    end
  end
end

class ::Hostgroup::Jail < Safemode::Jail
  allow :content_source, :rhsm_organization_label, :subscription_manager_configuration_url
end
