module Katello
  class ContentViewEnvironmentContentFacet < Katello::Model
    belongs_to :content_view_environment, :class_name => "::Katello::ContentViewEnvironment", :inverse_of => :content_view_environment_content_facets
    belongs_to :content_facet, :class_name => "::Katello::Host::ContentFacet", :inverse_of => :content_view_environment_content_facets

    validates :content_view_environment_id, presence: true
    validates :content_facet_id, presence: true, unless: :new_record?
  end
end
