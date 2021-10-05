module Katello
  class Api::V2::FileUnitsController < Api::V2::ApiController
    include Katello::Concerns::FilteredAutoCompleteSearch
    resource_description do
      name 'Files'
    end
    apipie_concern_subst(:a_resource => N_("a file"), :resource_id => "files")
    include Katello::Concerns::Api::V2::RepositoryContentController

    def default_sort
      %w(name asc)
    end

    private

    def repo_association
      :repository_id
    end
  end
end
