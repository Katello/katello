# load Katello configuration
path = File.expand_path('../lib', __FILE__)
$LOAD_PATH << path unless $LOAD_PATH.include? path
require 'katello/load_configuration'

# When adding new version requirement check out EPEL6 repository first
# and use this version if possible. Also check Fedora version (usually higher).
# With a pull request, send also link to our (or Fedora) koji with RPMs.
source 'http://rubygems.org'


# Reports - TODO this is hack that needs to be removed once ruport is officially released
if (`rpm -q rubygem-ruport` rescue "") =~ /^rubygem-ruport-1.7.0\S+/ && ! defined?(JRUBY_VERSION)
  #gem 'ruport', '>=1.7.0'
else
  #gem 'ruport', '>=1.7.0', :git => 'git://github.com/ruport/ruport.git'
end
#not an actual katello dependency, but
#Does not pull in  hashery, matches RPM
gem 'pdf-reader', '<= 1.1.1'

gem 'prawn'

# Load all sub-gemfiles from bundler.d directory
Dir[File.expand_path('bundler.d/*.rb', File.dirname(__FILE__))].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle), bundle)
end

gemspec
