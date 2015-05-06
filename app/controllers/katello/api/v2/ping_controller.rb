module Katello
  class Api::V2::PingController < Api::V2::ApiController
    resource_description do
      api_version "v2"
    end

    skip_before_filter :authorize
    before_filter :require_login, :only => [:index]

    api :GET, "/ping", N_("Shows status of system and it's subcomponents")
    description N_("This service is only available for authenticated users")
    def index
      respond_for_show :resource => Ping.ping
    end

    api :GET, "/status", N_("Shows version information")
    description N_("This service is available for unauthenticated users")
    def server_status
      # rubocop:disable SymbolName
      status = { :version    => Katello::VERSION,
                 :timeUTC    => Time.now.getutc }
      respond_for_show :resource => status, :template => "server_status"
    end
  end
end
