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
          "#{Katello::Engine.root}/spec/**/*_spec.rb",
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
          "#{Katello::Engine.root}/test/**/*_test.rb",
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
