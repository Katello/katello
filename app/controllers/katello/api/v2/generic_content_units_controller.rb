module Katello
  class Api::V2::GenericContentUnitsController < Api::V2::ApiController
    resource_description do
      name 'Content Units'
      param :content_type, String, desc: N_("Possible values: #{Katello::RepositoryTypeManager.generic_content_types.join(", ")}"), required: true
    end
    apipie_concern_subst(:a_resource => N_("a content unit"), :resource_id => "content_units")

    Katello::RepositoryTypeManager.generic_content_types(false).each do |type|
      api :GET, "/#{type.pluralize}", N_("List %s" % type.pluralize)
      api :GET, "/#{type.pluralize}/:id", N_("Show %s" % type.gsub(/_/, ' '))
      api :GET, "/repositories/:repository_id/#{type.pluralize}/:id", N_("Show %s" % type.gsub(/_/, ' '))
    end

    include Katello::Concerns::Api::V2::RepositoryContentController

    def default_sort
      %w(name asc)
    end

    def resource_class
      fail "Required param content_type is missing" unless params[:content_type]
      ::Katello::GenericContentUnit.where(content_type: params[:content_type].singularize)
    end

    private

    def repo_association
      :repository_id
    end
  end
end
