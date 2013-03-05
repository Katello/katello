# those groups are only available in the katello mode, otherwise bundler would require
# them to resolve dependencies (even when groups would be excluded from the list)
if Katello.early_config.katello?
  group :foreman do
    gem 'foreman_api', '>= 0.1.1'
  end
end
