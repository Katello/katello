require File.expand_path("../engine", File.dirname(__FILE__))

namespace :test do

  desc "Run the Katello plugin test suite."
  task :katello => ['db:test:prepare'] do
    # Set the test loader explicitly to ensure that the ci_reporter gem 
    # doesn't override our test runner
    ENV['TESTOPTS'] = "#{ENV['TESTOPTS']} #{Katello::Engine.root}/test/katello_test_runner.rb"

    test_task = Rake::TestTask.new('katello_test_task') do |t|
      t.libs << ["test", "#{Katello::Engine.root}/test", "spec", "#{Katello::Engine.root}/spec"]
      t.test_files = [
        "#{Katello::Engine.root}/test/models/repository_test.rb",
        "#{Katello::Engine.root}/test/models/activation_key_test.rb",
        "#{Katello::Engine.root}/spec/models/activation_key_spec.rb"
      ]
      t.verbose = true
    end

    Rake::Task[test_task.name].invoke
  end

end

Rake::Task[:test].enhance do
  Rake::Task['test:katello'].invoke
end
