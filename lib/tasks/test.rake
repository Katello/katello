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

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

Rake.application.remove_task 'db:test:prepare'

namespace :db do
  namespace :test do 
    task :prepare do |t|
      # rewrite the task to not do anything you don't want
    end
  end
end
