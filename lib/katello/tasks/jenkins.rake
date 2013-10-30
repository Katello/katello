begin
  require 'ci/reporter/rake/minitest'

  namespace :jenkins do
    namespace :katello do
      task :test => ['jenkins:setup:minitest', 'rake:test:katello:test']
    end
  end

rescue LoadError
  # ci/reporter/rake/rspec not present, skipping this definition
end
