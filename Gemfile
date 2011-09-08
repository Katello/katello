source 'http://repos.fedorapeople.org/repos/katello/gems/'

gem 'rails', '3.0.5'

gem 'json'
gem 'rest-client', :require => 'rest_client'
gem 'jammit'
gem 'sqlite3', :require => 'sqlite3'
gem 'pg'
# gem 'bson_ext', '>= 1.0.4'
gem 'rails_warden'
gem 'net-ldap'
gem 'oauth'

gem 'delayed_job', '>= 2.1.4'
gem 'daemons', '>= 1.1.4'
gem 'uuidtools'

# Stuff for view/display/frontend
gem 'haml', '>= 3.1.2'
gem 'haml-rails'
gem 'compass', '>= 0.11.5'
gem 'compass-960-plugin', '>= 0.10.4'
gem 'simple-navigation', '3.3.4'
gem 'scoped_search', '>= 2.3.3'
# Stuff for i18n
gem 'gettext_i18n_rails'
gem 'i18n_data', '>= 0.2.6', :require => 'i18n_data'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# @@@DEV_ONLY@@@
# Everything bellow the line above will NOT be used in production.
# Do not change the line contents, it's searched by sed during the build phase.

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri', '>=1.4.1'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

group :test, :development do
  # To use debugger
  gem 'ruby-debug'
  gem 'ZenTest', '>= 4.4.0'
  gem 'rspec-rails', '>= 2.0.0'
  gem 'autotest-rails', '>= 4.1.0'
  gem 'rcov', '>= 0.9.9'

  gem 'webrat', '>=0.7.3'
  gem 'nokogiri', '>= 1.5.0'

  #needed  for documentation
  gem 'yard', '>= 0.5.3'
  
  #needed by hudson
  gem 'ci_reporter','>= 1.6.3'
  gem 'gettext', '>= 1.9.3', :require => false
  gem 'ruby_parser'
  
  # profiler
  gem 'newrelic_rpm'
  
  #needed for unit tests
end
