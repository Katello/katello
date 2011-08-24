namespace :beaker do
  task :integration_tests => ["rake:configuration", "beaker:setup:rspec", 'beaker:rspec']
  require 'ci/reporter/rake/rspec'
  
  namespace :setup do
    task :pre_ci do
      ENV["CI_REPORTS"] = 'beaker/reports/'
      gem 'ci_reporter'
    end
    task :rspec => [:pre_ci, "ci:setup:rspec"]
  end
  
  task :rspec do
    sh %(rspec integration_spec/candlepin/)
  end
  
end

