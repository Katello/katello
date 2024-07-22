require File.expand_path("../engine", File.dirname(__FILE__))

namespace :test do
  namespace :katello do
    desc "Run the Katello plugin spec test suite."
    task :spec => ['db:test:prepare'] do
      spec_task = Rake::TestTask.new('katello_spec_task') do |t|
        t.libs << ["test", "#{Katello::Engine.root}/test", "spec", "#{Katello::Engine.root}/spec"]
        t.test_files = [
          "#{Katello::Engine.root}/spec/**/*_spec.rb",
        ]
        t.verbose = true
        t.warning = false
      end

      Rake::Task[spec_task.name].invoke
    end

    namespace :spec do
      desc "Run the Katello plugin spec test suite."
      task :routing => ['db:test:prepare'] do
        spec_task = Rake::TestTask.new('katello_spec_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test", "spec", "#{Katello::Engine.root}/spec"]
          t.test_files = [
            "#{Katello::Engine.root}/spec/routing/**/*_spec.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[spec_task.name].invoke
      end
    end

    desc "Run the Katello plugin unit test suite."
    task :test => ['db:test:prepare'] do
      test_task = Rake::TestTask.new('katello_test_task') do |t|
        t.libs << ["test", "#{Katello::Engine.root}/test"]
        if ENV['MATCH']
          tests = ENV['MATCH'].split(',')
          test_files = tests.map do |tst|
            Dir.glob("#{Katello::Engine.root}/test/**/*#{tst}*").select do |fl|
              fl.end_with?("_test.rb")
            end
          end
          test_files.flatten!
          t.test_files = test_files
          puts "Running Tests #{test_files.inspect}"
        else
          t.test_files = [
            "#{Katello::Engine.root}/test/scenarios/*_test.rb",
            "#{Katello::Engine.root}/test/models/**/*_test.rb",
            "#{Katello::Engine.root}/test/controllers/**/*_test.rb",
            "#{Katello::Engine.root}/test/**/*_test.rb",
          ]
        end
        t.verbose = true
        t.warning = false
      end

      Rake::Task[test_task.name].invoke
    end

    namespace :test do
      desc "Run the Katello plugin unit models test suite."
      task :models => ['db:test:prepare'] do
        test_task = Rake::TestTask.new('katello_models_test_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test"]
          t.test_files = [
            "#{Katello::Engine.root}/test/models/**/*_test.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[test_task.name].invoke
      end

      desc "Run the Katello plugin unit actions test suite."
      task :actions => ['db:test:prepare'] do
        test_task = Rake::TestTask.new('katello_actions_test_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test"]
          t.test_files = [
            "#{Katello::Engine.root}/test/actions/**/*_test.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[test_task.name].invoke
      end

      desc "Run the Katello plugin unit controllers test suite."
      task :controllers => ['db:test:prepare'] do
        test_task = Rake::TestTask.new('katello_controllers_test_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test"]
          t.test_files = [
            "#{Katello::Engine.root}/test/controllers/**/*_test.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[test_task.name].invoke
      end

      desc "Delete scenario vcr cassettes and run the katello scenario tests in live mode"
      task :live_scenarios => ['db:test:prepare'] do
        files = Dir[File.join(::Katello::Engine.root, 'test/fixtures/vcr_cassettes/scenarios/', '**/*.yml')]
        files.each { |file| File.delete(file) }

        ENV['mode'] = 'all'
        test_task = Rake::TestTask.new('katello_scenario_test_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test"]
          t.test_files = [
            "#{Katello::Engine.root}/test/scenarios/*_test.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[test_task.name].invoke
      end

      desc "Run the Katello plugin unit glue test suite."
      task :glue => ['db:test:prepare'] do
        test_task = Rake::TestTask.new('katello_glue_test_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test"]
          t.test_files = [
            "#{Katello::Engine.root}/test/glue/**/*_test.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[test_task.name].invoke
      end

      desc "Run the Katello plugin unit glue test suite."
      task :services => ['db:test:prepare'] do
        test_task = Rake::TestTask.new('katello_services_test_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test"]
          t.test_files = [
            "#{Katello::Engine.root}/test/services/**/*_test.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[test_task.name].invoke
      end

      desc "Run the Katello plulpcore tests."
      task :pulpcore => ['db:test:prepare'] do
        test_task = Rake::TestTask.new('katello_services_test_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test"]
          t.test_files = [
            "#{Katello::Engine.root}/test/**/pulp3/**/*_test.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[test_task.name].invoke
      end

      desc "Run the Katello plugin unit lib test suite."
      task :lib => ['db:test:prepare'] do
        test_task = Rake::TestTask.new('katello_lib_test_task') do |t|
          t.libs << ["test", "#{Katello::Engine.root}/test"]
          t.test_files = [
            "#{Katello::Engine.root}/test/lib/**/*_test.rb",
          ]
          t.verbose = true
          t.warning = false
        end

        Rake::Task[test_task.name].invoke
      end
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
