# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# this is for 0.8.7 (el6) vs 0.9.0+ compatibility
begin
  require 'rake/dsl_definition'
  require 'rake'
  include Rake::DSL
rescue Exception
  require 'rake'
end

task :default => [:spec]

Src::Application.load_tasks
