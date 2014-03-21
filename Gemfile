# The Gemfile for Katello is really only useful for running
# string extraction. The real dependency data is found
# in the gemspec
#
#
# This Rakefile rquires that the foreman code be checked out in a
# peer directory to katello.
#

source "http://rubygems.org"

FOREMAN_GEMFILE=File.expand_path('../../foreman/Gemfile', __FILE__)

unless File.exist?(FOREMAN_GEMFILE)
  puts <<MESSAGE
Foreman source code is not present. Please check out the foream code and try again.
MESSAGE

else
  self.instance_eval(Bundler.read_file(FOREMAN_GEMFILE))
end
