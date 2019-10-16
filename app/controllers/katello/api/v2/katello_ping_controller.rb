module Katello
  class Api::V2::KatelloPingController < Api::V2::ApiController
    resource_description do
      api_version "v2"
      resource_id "ping"
      api_base_url ""
    end

    skip_before_action :authorize
    before_action :require_login, :only => [:index]

    api :GET, "/katello/api/ping", N_("Shows status of Katello system and it's subcomponents")
    description N_("This service is only available for authenticated users")
    def index
      respond_for_show :resource => Katello::Ping.ping
    end

    api :GET, "/katello/api/status", N_("Shows version information")
    description N_("This service is available for unauthenticated users")
    def server_status
      respond_for_show :resource => Katello::Ping.status, :template => "server_status"
    end
  end
end
