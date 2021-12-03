module Katello
  module Hostgroup
    class ContentFacet < Katello::Model
      audited :associated_with => :lifecycle_environment
      self.table_name = 'katello_hostgroup_content_facets'
      include Facets::HostgroupFacet

      belongs_to :kickstart_repository, :class_name => "::Katello::Repository", :inverse_of => :kickstart_hostgroup_content_facets
      belongs_to :content_view, :inverse_of => :hostgroup_content_facets, :class_name => "Katello::ContentView"
      belongs_to :lifecycle_environment, :inverse_of => :hostgroup_content_facets, :class_name => "Katello::KTEnvironment"
      belongs_to :content_source, :class_name => "::SmartProxy", :inverse_of => :hostgroup_content_facets

      validates_with Katello::Validators::ContentViewEnvironmentValidator
      validates_with Katello::Validators::HostgroupKickstartRepositoryValidator
      validates_with ::AssociationExistsValidator, attributes: [:content_source]
    end
  end
end
