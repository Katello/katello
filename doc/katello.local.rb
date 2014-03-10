# This is the gemfile for foreman that will load the Katello engine.
# It belongs in foreman/bundler.d/

gem 'dynflow', :path => '../dynflow'
gemspec :path => '../katello', :development_group => :katello_dev
