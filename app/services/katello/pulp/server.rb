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
          :cert_auth => {
            :ssl_client_cert => ::Cert::Certs.ssl_client_cert,
            :ssl_client_key => ::Cert::Certs.ssl_client_key
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
