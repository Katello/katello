def configure_runcible
  if SETTINGS[:katello][:use_pulp]
    uri = URI.parse(SETTINGS[:katello][:pulp][:url])
    runcible_config = {
      :url      => "#{uri.scheme}://#{uri.host}",
      :api_path => uri.path,
      :user     => "admin",
      :oauth    => {:oauth_secret => SETTINGS[:katello][:pulp][:oauth_secret],
                    :oauth_key    => SETTINGS[:katello][:pulp][:oauth_key] }
    }

    runcible_config[:logger] = 'stdout' if ENV['logging'] == "true"
    Katello.pulp_server = Runcible::Instance.new(runcible_config)
  end
end
