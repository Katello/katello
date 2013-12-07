def configure_runcible
  if Katello.config[:use_pulp]
    uri                      = URI.parse(Katello.config.pulp.url)
    runcible_config          = {
        :url      => "#{uri.scheme}://#{uri.host}",
        :api_path => uri.path,
        :user     => "admin",
        :oauth    => { :oauth_secret => Katello.config.pulp.oauth_secret,
                       :oauth_key    => Katello.config.pulp.oauth_key }
    }

    runcible_config[:logger] = 'stdout' if ENV['logging'] == "true"
    Katello.pulp_server      = Runcible::Instance.new(runcible_config)
  end
end
