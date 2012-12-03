# set environment variable BUNDLER_ENABLE_RPM_PREFERRING to 'true' to enable bundler patch
# if enabled bundler prefers rpm-gems even if they are older version then gems in gem-repo
if ENV['BUNDLER_ENABLE_RPM_PREFERRING'] == 'true'
  require File.join(File.dirname(__FILE__), 'lib', 'bundler_patch_rpm-gems_preferred')
end

require './lib/util/boot_util'

# When adding new version requirement check out EPEL6 repository first
# and use this version if possible. Also check Fedora version (usually higher).
source 'http://rubygems.org'

gem 'rails', '~> 3.0.10'
gem 'thin', '>= 1.2.8'
gem 'tire', '>= 0.3.0', '< 0.4'
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem 'jammit', '>= 0.5.4'
gem 'pg'
gem 'rails_warden', '>= 0.5.2'
gem 'net-ldap'
gem 'oauth'
gem 'ldap_fluff'

# those groups are only available in the katello mode, otherwise bundler would require
# them to resolve dependencies (even when groups would be excluded from the list)
if Katello::BootUtil.katello?
  group :foreman do
    gem 'foreman_api', '>= 0.0.8'
  end
end

gem 'delayed_job', '~> 2.1.4'
gem 'daemons', '>= 1.1.4'
gem 'uuidtools'

# Stuff for view/display/frontend
gem 'haml', '>= 3.1.2'
gem 'haml-rails'
gem 'compass', '>= 0.11.5', '< 0.12'
gem 'compass-960-plugin', '>= 0.10.4', :require=> 'ninesixty'
gem 'simple-navigation', '>= 3.3.4'

# Stuff for i18n
gem 'gettext_i18n_rails'
gem 'i18n_data', '>= 0.2.6', :require => 'i18n_data'

# Reports
if system('rpm -q rubygem-ruport >/dev/null')
  gem 'ruport' , '>=1.7.0'
else
  gem 'ruport' , '>=1.7.0', :git => 'git://github.com/ruport/ruport.git'
end
gem 'prawn'
gem 'acts_as_reportable', '>=1.1.1', :require => 'ruport/acts_as_reportable'

# Documentation
gem "apipie-rails", '>= 0.0.12'

# Pulp API bindings
gem 'runcible', '~> 0.2.1'

gem 'anemone'

# In production mode we require only gems from :default group (without any
# group) via bundler_ext. To require groups bellow, set BUNDLER_EXT_GROUPS
# environment variable (in /etc/sysconfig/katello) and install development
# dependencies with yum install katello-devel-all. Or use bundler.

group :debugging do
  if RUBY_VERSION >= "1.9.2"
    gem 'debugger'
  elsif RUBY_VERSION == "1.9.1"
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
end

group :test, :development do
  gem 'redcarpet'
  gem 'ZenTest', '>= 4.4.0', :require => "autotest"
  gem 'rspec-rails', '>= 2.0.0'

  gem 'autotest-rails', '>= 4.1.0'

  gem 'webrat', '>=0.7.3'
  gem 'nokogiri', '>= 1.5.0'

  #needed for documentation
  gem 'yard', '>= 0.5.3'

  #needed by hudson
  gem 'ci_reporter', '>= 1.6.3'
  gem 'gettext', '>= 1.9.3', :require => false
  gem 'ruby_parser'
  gem 'sexp_processor' #dependency of ruby_parser

  #needed to generate routes in javascript
  gem "js-routes", :require => 'js_routes'
 
  gem 'minitest-rails'
  if RUBY_VERSION == "1.8.7"
    gem 'minitest_tu_shim'
  end

  #parallel_tests to make our specs go faster
  gem "parallel_tests"

  gem 'factory_girl_rails', "~> 1.7.0"

  #coverage
  if RUBY_VERSION >= "1.9.2"
    gem 'simplecov'
  else
    gem 'rcov', '>= 0.9.9'
  end
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
  gem 'therubyracer', "~> 0.10.2"
  gem 'jshintrb', '0.1.1'
end

group :development do
  # profiler
  gem 'newrelic_rpm'
  gem 'logical-insight'
end

group :development do
  # devboost just for dev mode
  gem 'rails-dev-boost'#, :require => 'rails_development_boost'
end

group :test do
  gem 'vcr'
  gem 'webmock'
end
