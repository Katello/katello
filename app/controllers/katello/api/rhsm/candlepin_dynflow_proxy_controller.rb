module Katello
  class Api::Rhsm::CandlepinDynflowProxyController < Api::V2::ApiController
    include Katello::Authentication::ClientAuthentication
    include ForemanTasks::Triggers
    include AbstractController::Callbacks

    skip_before_action :authorize, :only => [:upload_package_profile, :upload_profiles, :deb_package_profile]
    before_action :find_host, :only => [:upload_package_profile, :upload_profiles, :deb_package_profile]
    before_action :authorize_client_or_user, :only => [:upload_package_profile, :upload_profiles, :deb_package_profile]

    skip_before_action :check_media_type

    #api :PUT, "/consumers/:id/packages", N_("Update installed packages")
    #api :PUT, "/consumers/:id/profile", N_("Update installed packages")
    #param :id, String, :desc => N_("UUID of the consumer"), :required => true
    def upload_package_profile
      User.as_anonymous_admin do
        uploader = ::Katello::Host::PackageProfileUploader.new(
          host: @host,
          profile_string: request.raw_post
        )
        uploader.upload
        uploader.trigger_applicability_generation
      end
      render :json => Resources::Candlepin::Consumer.get(@host.subscription_facet.uuid)
    end

    api :PUT, "/consumers/:id/profiles", N_("Update installed packages, enabled repos, module inventory")
    param :id, String, :desc => N_("UUID of the consumer"), :required => true
    def upload_profiles
      User.as_anonymous_admin do
        uploader = ::Katello::Host::ProfilesUploader.new(
          host: @host,
          profile_string: request.raw_post
        )
        uploader.upload
        uploader.trigger_applicability_generation
      end
      render :json => Resources::Candlepin::Consumer.get(@host.subscription_facet.uuid)
    end

    def find_host(uuid = nil)
      params = request.path_parameters
      uuid ||= params[:id]
      facet = Katello::Host::SubscriptionFacet.where(:uuid => uuid).first
      if facet.nil?
        # check with candlepin if consumer is Gone, raises RestClient::Gone
        User.as_anonymous_admin { Resources::Candlepin::Consumer.get(uuid) }
        fail HttpErrors::NotFound, _("Couldn't find consumer '%s'") % uuid
      end
      @host = facet.host
    end

    rescue_from RestClient::Exception do |e|
      Rails.logger.error(pp_exception(e, with_backtrace: false))
      Rails.logger.error(e.backtrace.detect { |line| line.match("katello.*controller") })
      if request_from_katello_cli?
        render :json => { :errors => [e.http_body] }, :status => e.http_code
      else
        render :plain => e.http_body, :status => e.http_code
      end
    end

    def authorize_client_or_user
      client_authorized? || authorize
    end

    def client_authorized?
      authorized = authenticate_client && User.consumer?
      authorized = (User.current.uuid == @host.subscription_facet.uuid) if @host && User.consumer?
      authorized
    end
  end
end
