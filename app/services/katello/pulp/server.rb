module Katello
  module Pulp
    class Server
      def self.config(url, user_remote_id)
        uri = URI.parse(url)

        Runcible::Instance.new(
          :url => "#{uri.scheme}://#{uri.host.downcase}",
          :api_path => uri.path,
          :user => user_remote_id,
          :timeout => SETTINGS[:katello][:rest_client_timeout],
          :open_timeout => SETTINGS[:katello][:rest_client_timeout],
          :oauth => {
            :oauth_secret => SETTINGS[:katello][:pulp][:oauth_secret],
            :oauth_key => SETTINGS[:katello][:pulp][:oauth_key]
          },
          :logging => {
            :logger => ::Foreman::Logging.logger('katello/pulp_rest'),
            :exception => true,
            :info => true,
            :debug => true
          }
        )
      end
    end
  end
end
