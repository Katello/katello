# load Katello configuration
path = File.expand_path('../lib', __FILE__)
$LOAD_PATH << path unless $LOAD_PATH.include? path
require 'katello/load_configuration'

# When adding new version requirement check out EPEL6 repository first
# and use this version if possible. Also check Fedora version (usually higher).
# With a pull request, send also link to our (or Fedora) koji with RPMs.
source 'http://rubygems.org'

gem 'rails', '~> 3.2.8'
gem 'json'
gem 'rest-client', :require => 'rest_client'
gem 'jammit', '>= 0.5.4'
gem 'rails_warden', '>= 0.5.2'
gem 'net-ldap'
gem 'oauth'
gem 'ldap_fluff'

if defined? JRUBY_VERSION
  gem 'jruby-openssl'
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-postgres', :require => false
  gem 'activerecord-jdbcpostgresql-adapter', :require => false
  gem 'tire', '>= 0.3.0'
else
  gem 'thin', '>= 1.2.8'
  gem 'tire', '>= 0.3.0', '< 0.4'
  gem 'pg'
end

gem 'delayed_job', '~> 3.0.2'
gem 'delayed_job_active_record'
gem 'daemons', '>= 1.1.4'
gem 'uuidtools'

# Stuff for view/display/frontend
gem 'haml', '~> 3.1.2'
gem 'haml-rails', "= 0.3.4"
gem 'compass-rails'
gem 'compass'
gem 'compass-960-plugin', '>= 0.10.4', :require => 'ninesixty'
gem 'simple-navigation', '>= 3.3.4'

# Stuff for i18n
gem 'gettext_i18n_rails'
gem 'i18n_data', '>= 0.2.6', :require => 'i18n_data'

# Reports - TODO this is hack that needs to be removed once ruport is officially released
if (`rpm -q rubygem-ruport` rescue "") =~ /^rubygem-ruport-1.7.0\S+/ && ! defined? JRUBY_VERSION
  gem 'ruport', '>=1.7.0'
else
  gem 'ruport', '>=1.7.0', :git => 'git://github.com/ruport/ruport.git'
end
#not an actual katello dependency, but
#Does not pull in  hashery, matches RPM
gem 'pdf-reader', '<= 1.1.1'

gem 'prawn'
gem 'acts_as_reportable', '>=1.1.1', :require => 'ruport/acts_as_reportable'

# Documentation
gem "apipie-rails", '>= 0.0.13'

gem 'hooks'

# Better logging (syslog/rolling/trace)
gem 'logging', '>= 1.8.0'

# Load all sub-gemfiles from bundler.d directory
Dir[File.expand_path('bundler.d/*.rb', File.dirname(__FILE__))].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle), bundle)
end
