module Katello
  def self.pulp_server
    Katello::Pulp::Server.config(SETTINGS[:katello][:pulp][:url], User.remote_user)
  end
end
