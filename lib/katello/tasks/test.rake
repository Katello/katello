require File.expand_path("../engine", File.dirname(__FILE__))

namespace :test do

  namespace :katello do

    # Set the test loader explicitly to ensure that the ci_reporter gem
    # doesn't override our test runner
    def set_test_runner
      ENV['TESTOPTS'] = "#{ENV['TESTOPTS']} #{Katello::Engine.root}/test/katello_test_runner.rb"
    end

    desc "Run the Katello plugin spec test suite."
    task :spec => ['db:test:prepare'] do
      set_test_runner

      spec_task = Rake::TestTask.new('katello_spec_task') do |t|
        t.libs << ["test", "#{Katello::Engine.root}/test", "spec", "#{Katello::Engine.root}/spec"]
        t.test_files = [
          "#{Katello::Engine.root}/spec/helpers/**/*_spec.rb",
          "#{Katello::Engine.root}/spec/models/**/*_spec.rb",
          "#{Katello::Engine.root}/spec/routing/**/*_spec.rb",
          "#{Katello::Engine.root}/spec/lib/**/*_spec.rb",
          "#{Katello::Engine.root}/spec/controllers/*.rb",
          "#{Katello::Engine.root}/spec/controllers/api/*.rb"
        ]
        t.verbose = true
      end

      Rake::Task[spec_task.name].invoke
    end

    desc "Run the Katello plugin unit test suite."
    task :test => ['db:test:prepare'] do
      set_test_runner

      test_task = Rake::TestTask.new('katello_test_task') do |t|
        t.libs << ["test", "#{Katello::Engine.root}/test"]
        t.test_files = [
          "#{Katello::Engine.root}/test/services/**/*_test.rb",
          "#{Katello::Engine.root}/test/controllers/api/v1/*_test.rb",
          "#{Katello::Engine.root}/test/controllers/api/v2/*_test.rb",
          "#{Katello::Engine.root}/test/actions/**/*_test.rb",
          "#{Katello::Engine.root}/test/glue/**/*_test.rb",
          "#{Katello::Engine.root}/test/helpers/*_test.rb",
          "#{Katello::Engine.root}/test/lib/navigation/*_test.rb",
          "#{Katello::Engine.root}/test/lib/validators/*_test.rb",
          "#{Katello::Engine.root}/test/lib/repo_discovery_test.rb",
          "#{Katello::Engine.root}/test/models/authorization/*_test.rb",
          "#{Katello::Engine.root}/test/models/concerns/*_test.rb",
          "#{Katello::Engine.root}/test/models/association_test.rb",
          "#{Katello::Engine.root}/test/models/repository_test.rb",
          "#{Katello::Engine.root}/test/models/system_test.rb",
          "#{Katello::Engine.root}/test/models/distributor_test.rb",
          "#{Katello::Engine.root}/test/models/activation_key_test.rb",
          "#{Katello::Engine.root}/test/models/content_view_test.rb",
          "#{Katello::Engine.root}/test/models/content_view_filter_test.rb",
          "#{Katello::Engine.root}/test/models/content_view_erratum_filter_rule_test.rb",
          "#{Katello::Engine.root}/test/models/content_view_package_filter_rule_test.rb",
          "#{Katello::Engine.root}/test/models/content_view_package_group_filter_rule_test.rb",
          "#{Katello::Engine.root}/test/models/kt_environment_test.rb",
          "#{Katello::Engine.root}/test/models/organization_test.rb",
          "#{Katello::Engine.root}/test/models/puppet_module_test.rb",
          "#{Katello::Engine.root}/test/models/pulp_sync_status_test.rb"
        ]
        t.verbose = true
      end

      Rake::Task[test_task.name].invoke
    end
  end

  desc "Run the entire Katello plugin test suite"
  task :katello do
    Rake::Task['test:katello:spec'].invoke
    Rake::Task['test:katello:test'].invoke
  end

end

Rake::Task[:test].enhance do
  Rake::Task['test:katello'].invoke
end
