module Katello
  class Api::V2::OstreeBranchesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("an ostree branch"), :resource => "ostree_branch")
    include Katello::Concerns::Api::V2::RepositoryContentController

    private

    def resource_class
      OstreeBranch
    end

    def filter_by_content_view_filter(filter)
      resource_class.where(:uuid => filter.send("#{singular_resource_name}_rules").pluck(:uuid))
    end
  end
end
