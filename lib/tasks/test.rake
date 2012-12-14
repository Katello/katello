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


if ENV['method']
  if not ENV['method'].starts_with?('test_')
    ENV['method'] = "test_#{ENV['method']}"
  end

  if ENV['TESTOPTS']
    ENV['TESTOPTS'] += "--name=#{ENV['method']}"
  else
    ENV['TESTOPTS'] = "--name=#{ENV['method']}"
  end
end

MINITEST_TASKS  = %w(models helpers controllers glue lib)
GLUE_LAYERS     = %w(pulp elasticsearch)

Rake::Task["minitest"].clear
Rake::Task["minitest:models"].clear

desc 'Runs all minitest tests'
MiniTest::Rails::Tasks::SubTestTask.new(:minitest) do |t|
  t.libs.push 'test'
  t.pattern = "test/#{task}/**/*_test.rb"
end

namespace 'minitest' do
  Rake::Task["db:test:prepare"].clear

  MINITEST_TASKS.each do |task|
    if ENV['test']
      #Rake::Task["minitest:models"].clear
      Rake::Task["db:test:prepare"].clear
      MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
        t.libs.push 'test'
        t.pattern = "test/#{task}/#{ENV['test']}_test.rb"
      end
    else
      desc "Runs the #{task} tests"

      MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
        t.libs.push 'test'
        t.pattern = "test/#{task}/**/*_test.rb"
      end
    end
  end

  namespace :glue do

    GLUE_LAYERS.each do |task|
      if ENV['test']
        MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
          t.libs.push 'test'
          t.pattern = "test/glue/#{task}/#{ENV['test']}_test.rb"
        end   
      else
        desc "Runs the #{task} glue layer tests"

        MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
          t.libs.push 'test'
          t.pattern = "test/glue/#{task}/**/*_test.rb"
        end
      end
    end

  end

end
