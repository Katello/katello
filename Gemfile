# set environment variable BUNDLER_ENABLE_RPM_PREFERRING to 'true' to enable bundler patch
# if enabled bundler prefers rpm-gems even if they are older version then gems in gem-repo
if ENV['BUNDLER_ENABLE_RPM_PREFERRING'] == 'true'
  require File.join(File.dirname(__FILE__), 'lib', 'bundler_patch_rpm-gems_preferred')
end

source 'http://repos.fedorapeople.org/repos/katello/gems/'

# When adding new version requirement check out EPEL6 repository first
# and use this version if possible. Also check Fedora version (usually higher).
gem 'rails', '>= 3.0.10'
gem 'thin', '>= 1.2.8'

gem 'tire', '>= 0.3.0', '< 0.4'
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem 'jammit'
gem 'pg'
# gem 'bson_ext', '>= 1.0.4'
gem 'rails_warden'
gem 'net-ldap'
gem 'oauth'
gem 'ldap_fluff'

gem 'delayed_job', '~> 2.1.4'
gem 'daemons', '>= 1.1.4'
gem 'uuidtools'

# Stuff for view/display/frontend
gem 'haml', '>= 3.1.2'
gem 'haml-rails'
gem 'compass', '>= 0.11.5', '< 0.12'
gem 'compass-960-plugin', '>= 0.10.4'
gem 'simple-navigation', '>= 3.3.4'
# Stuff for i18n
gem 'gettext_i18n_rails'
gem 'i18n_data', '>= 0.2.6', :require => 'i18n_data'

# reports
gem 'ruport', '>=1.6.3'
gem 'acts_as_reportable', '>=1.1.1'

gem "apipie-rails"


# Pulp API bindings
lib_path = "../../runcible"
if File.exist?(lib_path)
  gem 'runcible', :path => lib_path
else
  gem 'runcible'
end

# Use unicorn as the web server
# gem 'unicorn'

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
  gem 'redcarpet'
  if RUBY_VERSION >= "1.9.1"
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
  gem 'ZenTest', '>= 4.4.0'
  gem 'rspec-rails', '>= 2.0.0'
  #gem 'autotest-rails', '>= 4.1.0'
  gem 'rcov', '>= 0.9.9'

  gem 'webrat', '>=0.7.3'
  gem 'nokogiri', '>= 1.5.0'

  #needed  for documentation
  gem 'yard', '>= 0.5.3'

  #needed by hudson
  gem 'ci_reporter', '>= 1.6.3'
  gem 'gettext', '>= 1.9.3', :require => false
  gem 'ruby_parser'

  #needed to generate routes in javascript
  gem "js-routes", :require => 'js_routes'
 
  gem 'minitest-rails'
  gem 'minitest_tu_shim'
  gem 'factory_girl'
end

group :profiling do
  #needed for profiling
  gem 'ruby-prof'
end

group :jshintrb do
  #needed for unit tests
  #
  #needed for syntax checking
  gem 'libv8'
  gem 'therubyracer'
  gem 'jshintrb', '0.1.1'
end

group :development do
  # profiler
  gem 'newrelic_rpm'
  gem 'logical-insight'
end

group :devboost do
  gem 'rails-dev-boost', :require => 'rails_development_boost'
end

group :test do
  gem 'vcr'
  gem 'webmock'
end
