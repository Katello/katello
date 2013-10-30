require File.expand_path("../engine", File.dirname(__FILE__))

namespace :test do
  namespace :katello do
    task :test => ['db:test:prepare', 'test:katello:katello_test']
    task :spec => ['db:test:prepare', 'test:katello:katello_spec']

    Rake::TestTask.new(:katello_test) do |t|
      t.libs << ["test", "#{Katello::Engine.root}/test"]
      t.test_files = [
        "#{Katello::Engine.root}/test/models/repository_test.rb"
      ]
      t.verbose = true
    end

    Rake::TestTask.new(:katello_spec) do |t|
      t.libs << ["test", "#{Katello::Engine.root}/test", "spec", "#{Katello::Engine.root}/spec"]
      t.test_files = [
        "#{Katello::Engine.root}/spec/models/activation_key_spec.rb"
      ]
      t.verbose = true
    end
  end

  desc "Test Katello plugin"
  task 'katello' do
    Rake::Task['test:katello:test'].invoke
    Rake::Task['test:katello:spec'].invoke
  end

end

Rake::Task[:test].enhance do
  Rake::Task['test:katello'].invoke
end
