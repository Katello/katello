# those groups are only available in the katello mode, otherwise bundler would require
# them to resolve dependencies (even when groups would be excluded from the list)
if Katello::BootUtil.katello?
  group :foreman do
    gem 'foreman_api', '>= 0.0.8'
  end
end
