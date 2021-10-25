module Katello
  class Api::V2::GenericContentUnitsController < Api::V2::ApiController
    Katello::RepositoryTypeManager.generic_content_types(false).each do |type|
      apipie_concern_subst(:a_resource => N_(type), :resource_id => type.pluralize)
      resource_description do
        name type.pluralize.titleize
      end
    end

    include Katello::Concerns::Api::V2::RepositoryContentController

    def default_sort
      %w(name asc)
    end

    def resource_class
      ::Katello::GenericContentUnit.where(content_type: params[:content_type].singularize)
    end

    private

    def repo_association
      :repository_id
    end
  end
end
