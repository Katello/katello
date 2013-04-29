# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
begin
  require 'ci/reporter/rake/rspec'
  namespace :hudson do
    task :spec => ["rake:configuration", "hudson:setup:rspec", 'spec']

    namespace :setup do
      task :pre_ci do
        ENV["CI_REPORTS"] = 'hudson/reports/spec/'
        gem 'ci_reporter'
      end
      task :rspec => [:pre_ci, "ci:setup:rspec"]
    end
  end
rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end

