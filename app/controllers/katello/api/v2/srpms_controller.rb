module Katello
  class Api::V2::SrpmsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("SRPM details"), :resource => "srpms")
    include Katello::Concerns::Api::V2::RepositoryContentController

    api :GET, "/srpms", N_("List srpms")
    param :organization_id, :number, :desc => N_("Organization identifier")
    param :repository_id, :number, :desc => N_("Repository identifier")
    param :environment_id, :number, :desc => N_("Environment identifier")
    param :content_view_version_id, :number, :desc => N_("Content View Version identifier")
    param_group :search, Api::V2::ApiController
    def index
      super
    end

    def available_for_content_view_version(version)
      version.available_packages
    end

    def default_sort
      lambda { |query| query.default_sort }
    end
  end
end
