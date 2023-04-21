module Katello
  class Api::V2::SimpleContentAccessController < Api::V2::ApiController
    before_action :find_organization

    resource_description do
      description "Red Hat subscriptions management platform."
      api_version 'v2'
    end

    api :GET, "/organizations/:organization_id/simple_content_access/eligible",
      N_("Check if the specified organization is eligible for Simple Content Access")
    def eligible
      ::Foreman::Deprecation.api_deprecation_warning("This endpoint is deprecated and will be removed in a future release. All organizations are now eligible for Simple Content Access.")
      eligible = @organization.simple_content_access_eligible?
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
    param :auto_create_overrides, :bool, :desc => N_("Automatically create disabled content overrides for custom products which do not have an attached subscription"), :required => false, :default => true
    def enable
      auto_create = params.key?(:auto_create_overrides) ? ::Foreman::Cast.to_bool(params[:auto_create_overrides]) : true
      task = async_task(::Actions::Katello::Organization::SimpleContentAccess::Enable, params[:organization_id], auto_create_overrides: auto_create)
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
