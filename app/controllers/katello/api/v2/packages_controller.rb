module Katello
  class Api::V2::PackagesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package"), :resource => "packages")
    include Katello::Concerns::Api::V2::RepositoryContentController

    api :GET, "/packages", N_("List packages")
    api :GET, "/repositories/:repository_id/packages", N_("List packages")
    param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
    param :repository_id, :number, :desc => N_("repository identifier")
    param_group :search, Api::V2::ApiController
    def index
      super
    end

    private

    def sort_params
      {sort_by: 'nvra'}
    end
  end
end
