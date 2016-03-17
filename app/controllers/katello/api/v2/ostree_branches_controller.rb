module Katello
  class Api::V2::OstreeBranchesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("an ostree branch"), :resource => "ostree_branches")
    include Katello::Concerns::Api::V2::RepositoryContentController

    def default_sort
      %w(version_date desc)
    end

    private

    def resource_class
      OstreeBranch
    end
  end
end
