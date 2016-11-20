module Katello
  module Pulp
    class Server
      def self.config(url, user_remote_id)
        uri = URI.parse(url)

        runcible_params = {
          :url => "#{uri.scheme}://#{uri.host.downcase}",
          :api_path => uri.path,
          :user => user_remote_id,
          :timeout => SETTINGS[:katello][:rest_client_timeout],
          :open_timeout => SETTINGS[:katello][:rest_client_timeout],
          :logging => {
            :logger => ::Foreman::Logging.logger('katello/pulp_rest'),
            :exception => true,
            :info => true,
            :debug => true
          }
        }

        if (ca_cert = SETTINGS[:katello][:pulp][:ca_cert_file])
          runcible_params[:ca_cert_file] = ca_cert
        end

        if Setting[:use_pulp_oauth]
          runcible_params[:oauth] = {
            :oauth_secret => SETTINGS[:katello][:pulp][:oauth_secret],
            :oauth_key => SETTINGS[:katello][:pulp][:oauth_key]
          }
        else
          runcible_params[:cert_auth] = {
            :ssl_client_cert => ::Cert::Certs.ssl_client_cert,
            :ssl_client_key => ::Cert::Certs.ssl_client_key
          }
        end

        Runcible::Instance.new(runcible_params)
      end
    end
  end
end
