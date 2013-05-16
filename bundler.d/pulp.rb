# those groups are only available in the katello mode, otherwise bundler would require
# them to resolve dependencies (even when groups would be excluded from the list)
if Katello.early_config.katello?
  group :pulp do
    # Pulp API bindings
    gem 'runcible', '~> 0.4.7'
    gem 'anemone'
  end
end
