begin
  require "ci/reporter/rake/minitest"

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
  end

rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end
