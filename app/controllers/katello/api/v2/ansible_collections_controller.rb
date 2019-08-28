module Katello
  class Api::V2::AnsibleCollectionsController < Api::V2::ApiController
    resource_description do
      name 'Ansible Collections'
    end
    apipie_concern_subst(:a_resource => N_("an ansible collection"), :resource_id => "ansible_collections")
    include Katello::Concerns::Api::V2::RepositoryContentController

    def index
      sort_by, sort_order, options = sort_options
      options[:includes] = [:tags]
      respond(:collection => scoped_search(index_relation, sort_by, sort_order, options))
    end

    def default_sort
      %w(name asc)
    end

    private

    def repo_association
      :repository_id
    end
  end
end
