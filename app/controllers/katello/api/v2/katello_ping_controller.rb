module Katello
  class Api::V2::KatelloPingController < Api::V2::ApiController
    resource_description do
      api_version "v2"
      api_base_url "/katello/api"
    end

    skip_before_action :authorize
    before_action :require_login, :only => [:index]

    api :GET, "/ping", N_("Shows status of Katello system and it's subcomponents")
    description N_("This service is only available for authenticated users")
    def index
      respond_for_show :resource => Katello::Ping.ping
    end

    api :GET, "/status", N_("Shows version information")
    description N_("This service is available for unauthenticated users")
    def server_status
      respond_for_show :resource => Katello::Ping.status, :template => "server_status"
    end
  end
end
