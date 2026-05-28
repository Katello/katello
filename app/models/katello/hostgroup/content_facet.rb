module Katello
  module Hostgroup
    class ContentFacet < Katello::Model
      audited :associated_with => :content_view_environment
      self.table_name = 'katello_hostgroup_content_facets'
      include Facets::HostgroupFacet

      belongs_to :kickstart_repository, :class_name => "::Katello::Repository", :inverse_of => :kickstart_hostgroup_content_facets
      belongs_to :content_view_environment, :class_name => "Katello::ContentViewEnvironment", :inverse_of => :hostgroup_content_facets
      belongs_to :content_source, :class_name => "::SmartProxy", :inverse_of => :hostgroup_content_facets

      validates_with Katello::Validators::HostgroupKickstartRepositoryValidator
      validates_with Katello::Validators::ContentViewEnvironmentValidator
      validates_with ::AssociationExistsValidator, attributes: [:content_source]

      def content_view_id
        content_view_environment&.content_view_id
      end

      def lifecycle_environment_id
        content_view_environment&.environment_id
      end

      def content_view
        content_view_environment&.content_view
      end

      def lifecycle_environment
        content_view_environment&.lifecycle_environment
      end
    end
  end
end
