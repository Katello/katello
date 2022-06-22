module Katello
  class Api::V2::SimpleContentAccessController < Api::V2::ApiController
    before_action :find_organization
    before_action :check_upstream_connection

    resource_description do
      description "Red Hat subscriptions management platform."
      api_version 'v2'
    end

    api :GET, "/organizations/:organization_id/simple_content_access/eligible",
      N_("Check if the specified organization is eligible for Simple Content Access")
    def eligible
      eligible = @organization.upstream_consumer.simple_content_access_eligible?
      render json: { simple_content_access_eligible: eligible }
    end

    api :GET, "/organizations/:organization_id/simple_content_access/status",
      N_("Check if the specified organization has Simple Content Access enabled")
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    def status
      status = @organization.simple_content_access?
      render json: { simple_content_access: status }
    end

    api :PUT, "/organizations/:organization_id/simple_content_access/enable",
      N_("Enable simple content access for a manifest")
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    def enable
      task = async_task(::Actions::Katello::Organization::SimpleContentAccess::Enable, params[:organization_id])
      respond_for_async :resource => task
    end

    api :PUT, "/organizations/:organization_id/simple_content_access/disable",
      N_("Disable simple content access for a manifest")
    param :organization_id, :number, :desc => N_("Organization ID"), :required => true
    def disable
      task = async_task(::Actions::Katello::Organization::SimpleContentAccess::Disable, params[:organization_id])
      respond_for_async :resource => task
    end
  end
end
