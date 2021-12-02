require File.expand_path("../engine", File.dirname(__FILE__))

begin
  namespace :jenkins do
    task :katello do
      Rake::Task['jenkins:setup:minitest'].invoke
      Rake::Task['rake:test:katello'].invoke
    end

    task 'katello:spec' do
      Rake::Task['jenkins:setup:minitest'].invoke
      Rake::Task['rake:test:katello:spec'].invoke
    end

    task 'katello:test' do
      Rake::Task['jenkins:setup:minitest'].invoke
      Rake::Task['rake:test:katello:test'].invoke
    end

    desc "Runs puplcore integration tests"
    task 'katello:pulpcore' do
      Rake::Task['jenkins:setup:minitest'].invoke
      Rake::Task['rake:test:katello:test:pulpcore'].invoke
    end
  end
rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end
