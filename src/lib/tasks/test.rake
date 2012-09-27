begin
  require 'rspec/core'
  require 'rspec/core/rake_task'

  namespace "test" do
    ["headpin"].each do |app|
      desc "Invoke #{app} RSpec tests"
      task "#{app}" do
        spec_prereq = Rails.configuration.generators.options[:rails][:orm] == :active_record ?  "db:test:prepare" : :noop
        t = RSpec::Core::RakeTask.new(spec_prereq).instance_eval do |i|
          self.pattern = ["./spec/**/*_spec.rb"]
          self.rspec_opts = "--tag '~katello'"
          task "#{app}_spec" do
            RakeFileUtils.send(:verbose, verbose) do
              if files_to_run.empty?
                puts "No examples matching #{pattern} could be found"
              else
                begin
                  ruby(spec_command)
                rescue
                  puts failure_message if failure_message
                  raise("ruby #{spec_command} failed") if fail_on_error
                end
              end
            end
          end
        end
        t.reenable
        t.invoke
      end
    end
end
rescue LoadError
  # rspec not present, skipping this definition
end

namespace :minitest do
  ['glue'].each do |task|
    MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
      t.libs.push 'test'
      t.pattern = "test/#{task}/**/*_test.rb"
    end   
  end
end

namespace :minitest do
  ['models'].each do |test_type|
    if ENV['test']
      Rake::Task["minitest:models"].clear
      Rake::Task["db:test:prepare"].clear
      MiniTest::Rails::Tasks::SubTestTask.new(test_type => 'test:prepare') do |t|
        t.libs.push 'test'
        t.pattern = "test/#{test_type}/#{ENV['test']}_test.rb"
      end   
    end
  end
=begin
  task 'models:authorization' do |task|
    if ENV['test']
      Rake::Task["db:test:prepare"].clear
      Rake::Task["minitest:models"].clear
      MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
        t.libs.push 'test'
        t.pattern = "test/models/authorization/#{ENV['test']}_authorization_test.rb"
      end   
    end
  end
=end
end
