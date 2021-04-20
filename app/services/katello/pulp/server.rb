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
            :ssl_client_cert => ::Cert::Certs.ssl_client_cert,
            :ssl_client_key => ::Cert::Certs.ssl_client_key
          }
        }

        if (ca_cert = ::Cert::Certs.backend_ca_cert_file(:pulp))
          runcible_params[:ca_cert_file] = ca_cert
          runcible_params[:verify_ssl] = true
        end

        Runcible::Instance.new(runcible_params)
      end
    end
  end
end
