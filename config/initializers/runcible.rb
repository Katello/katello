require 'util/thread_session'

if Katello.config.use_pulp

  # override Runcible's default configuration error message
  module Runcible
    class ConfigurationUndefinedError
      def self.message
        "Runcible configuration not defined. Is User.current set?"
      end
    end
  end

  uri = URI.parse(Katello.config.pulp.url)

  Katello.pulp_server = Runcible::Instance.new({
    :url      => "#{uri.scheme}://#{uri.host.downcase}",
    :api_path => uri.path,
    :timeout      => Katello.config.rest_client_timeout,
    :open_timeout => Katello.config.rest_client_timeout,
    :oauth    => {:oauth_secret => Katello.config.pulp.oauth_secret,
                  :oauth_key    => Katello.config.pulp.oauth_key },
    :logging  => {:logger     => ::Logging.logger['pulp_rest'],
                  :exception  => true,
                  :debug      => true }
  })


end