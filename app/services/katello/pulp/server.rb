module Katello
  module Pulp
    class Server
      def self.config(url, user_remote_id)
        uri = URI.parse(url)

        runcible_params = {
          :url => "#{uri.scheme}://#{uri.host.downcase}:#{uri.port}",
          :api_path => uri.path,
          :user => user_remote_id,
          :timeout => SETTINGS[:katello][:rest_client_timeout],
          :open_timeout => SETTINGS[:katello][:rest_client_timeout],
          :logging => {
            :logger => ::Foreman::Logging.logger('katello/pulp_rest'),
            :exception => true,
            :info => true,
            :debug => true
          },
          :cert_auth => {
            :ssl_client_cert => '/etc/pki/katello/certs/pulp-client.crt',
            :ssl_client_key => '/etc/pki/katello/private/pulp-client.key'
          }
        }

        if (ca_cert = SETTINGS[:katello][:pulp][:ca_cert_file])
          runcible_params[:ca_cert_file] = ca_cert
        end

        runcible_params[:verify_ssl] = SETTINGS[:katello][:pulp][:verify_ssl] if SETTINGS[:katello][:pulp].key?(:verify_ssl)

        Runcible::Instance.new(runcible_params)
      end
    end
  end
end
