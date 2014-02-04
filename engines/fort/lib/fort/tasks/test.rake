require File.expand_path("../engine", File.dirname(__FILE__))

namespace :test do

  namespace :fort do

    # Set the test loader explicitly to ensure that the ci_reporter gem
    # doesn't override our test runner
    def set_test_runner
      ENV['TESTOPTS'] = "#{ENV['TESTOPTS']} #{Katello::Engine.root}/test/katello_test_runner.rb"
    end

    desc "Run the fort plugin unit test suite."
    task :test => ['db:test:prepare'] do
      set_test_runner

      test_task = Rake::TestTask.new('katello_test_task') do |t|
        t.libs << ["test", "#{Fort::Engine.root}/test"]
        t.test_files = [
          "#{Fort::Engine.root}/test/controllers/fort/api/v2/*_test.rb",
          "#{Fort::Engine.root}/test/controllers/fort/api/v1/*_test.rb",
          "#{Fort::Engine.root}/test/models/*_test.rb"
        ]
        t.verbose = true
      end
      
      Rake::Task[test_task.name].invoke
    end
  end

  desc "Run the entire Katello plugin test suite"
  task :fort do
    Rake::Task['test:fort:test'].invoke
  end

end

Rake::Task[:test].enhance do
  Rake::Task['test:fort'].invoke
end
