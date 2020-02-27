require File.expand_path("../engine", File.dirname(__FILE__))

begin
  namespace :jenkins do
    ENV['USE_MEAN_TIME_REPORTER'] = '1' unless ENV['USE_MEAN_TIME_REPORTER'] == '0'

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
  end
rescue LoadError # rubocop:disable Lint/SuppressedException
  # ci/reporter/rake/rspec not present, skipping this definition
end
