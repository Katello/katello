require File.expand_path("../engine", File.dirname(__FILE__))

namespace :test do

  desc "Run the Katello plugin test suite."
  task :katello => ['db:test:prepare'] do
    # Set the test loader explicitly to ensure that the ci_reporter gem
    # doesn't override our test runner
    ENV['TESTOPTS'] = "#{ENV['TESTOPTS']} #{Katello::Engine.root}/test/katello_test_runner.rb"

    spec_task = Rake::TestTask.new('katello_spec_task') do |t|
      t.libs << ["test", "#{Katello::Engine.root}/test", "spec", "#{Katello::Engine.root}/spec"]
      t.test_files = [
        "#{Katello::Engine.root}/spec/helpers/**/*_spec.rb",
        "#{Katello::Engine.root}/spec/models/**/*_spec.rb",
        "#{Katello::Engine.root}/spec/routing/**/*_spec.rb",
        "#{Katello::Engine.root}/spec/controllers/*.rb",
        "#{Katello::Engine.root}/spec/lib/**/*_spec.rb",
        "#{Katello::Engine.root}/spec/controllers/*.rb",
        "#{Katello::Engine.root}/spec/controllers/api/*.rb"
      ]
      t.verbose = true
    end

    test_task = Rake::TestTask.new('katello_test_task') do |t|
      t.libs << ["test", "#{Katello::Engine.root}/test"]
      t.test_files = [
        "#{Katello::Engine.root}/test/controllers/api/v1/*_test.rb",
        "#{Katello::Engine.root}/test/controllers/api/v2/*_test.rb",
        "#{Katello::Engine.root}/test/glue/**/*_test.rb",
        "#{Katello::Engine.root}/test/helpers/*_test.rb",
        "#{Katello::Engine.root}/test/lib/navigation/*_test.rb",
        "#{Katello::Engine.root}/test/lib/validators/*_test.rb",
        "#{Katello::Engine.root}/test/controllers/content_views_controller_test.rb",
        "#{Katello::Engine.root}/test/controllers/filter_rules_controller_test.rb",
        "#{Katello::Engine.root}/test/controllers/filters_controller_test.rb",
        "#{Katello::Engine.root}/test/controllers/products_controller_test.rb",
        "#{Katello::Engine.root}/test/controllers/providers_controller_test.rb",
        "#{Katello::Engine.root}/test/controllers/systems_controller_test.rb",
        "#{Katello::Engine.root}/test/lib/repo_discovery_test.rb",
        "#{Katello::Engine.root}/test/models/authorization/*_test.rb",
        "#{Katello::Engine.root}/test/models/association_test.rb",
        "#{Katello::Engine.root}/test/models/repository_test.rb",
        "#{Katello::Engine.root}/test/models/system_test.rb",
        "#{Katello::Engine.root}/test/models/distributor_test.rb",
        "#{Katello::Engine.root}/test/models/activation_key_test.rb",
        "#{Katello::Engine.root}/test/models/changeset_test.rb",
        "#{Katello::Engine.root}/test/models/content_view_test.rb",
        "#{Katello::Engine.root}/test/models/content_view_version_test.rb",
        "#{Katello::Engine.root}/test/models/deletion_changeset_test.rb",
        "#{Katello::Engine.root}/test/models/erratum_rule_test.rb",
        "#{Katello::Engine.root}/test/models/filter_test.rb",
        "#{Katello::Engine.root}/test/models/kt_environment_test.rb",
        "#{Katello::Engine.root}/test/models/organization_test.rb",
        "#{Katello::Engine.root}/test/models/organization_destroyer_test.rb",
        "#{Katello::Engine.root}/test/models/package_rule_test.rb",
        "#{Katello::Engine.root}/test/models/package_group_rule_test.rb",
        "#{Katello::Engine.root}/test/models/content_view_definition_test.rb",
        "#{Katello::Engine.root}/test/models/puppet_module_test.rb",
        "#{Katello::Engine.root}/test/models/pulp_sync_status_test.rb"
      ]
      t.verbose = true
    end

    Rake::Task[test_task.name].invoke
    Rake::Task[spec_task.name].invoke
  end

end

Rake::Task[:test].enhance do
  Rake::Task['test:katello'].invoke
end
