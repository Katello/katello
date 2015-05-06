module Katello
  class Api::V2::PackageGroupsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package group"), :resource => "package_groups")
    include Katello::Concerns::Api::V2::RepositoryContentController

    private

    def repo_association
      :repo_id
    end
  end
end
