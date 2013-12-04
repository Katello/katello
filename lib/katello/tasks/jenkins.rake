require File.expand_path("../engine", File.dirname(__FILE__))

begin

  namespace :jenkins do
    task :katello do
      Rake::Task['jenkins:setup:minitest'].invoke
      Rake::Task['rake:test:katello'].invoke
    end
  end

rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end
