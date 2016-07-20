module Katello
  class Api::V2::UebercertsController < Api::V2::ApiController
    before_action :find_organization, :only => [:show]

    resource_description do
      api_version 'v2'
      api_base_url "/katello/api"
    end

    api :GET, "/organizations/:organization_id/uebercert", N_("Show an ueber certificate for an organization")
    param :regenerate, :bool, :desc => N_("When set to 'True' certificate will be re-issued")
    def show
      @organization.generate_debug_cert if (params[:regenerate] || '').downcase == 'true'
      respond :resource => @organization.debug_cert
    end
  end
end
