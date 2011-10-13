require 'rspec/core'
require 'rspec/core/rake_task'
require 'spec_helper.rb'

namespace "test" do
  ["katello", "headpin"].each do |app|
    desc "Invoke #{app} RSpec tests"
    task "#{app}_tests" do
      spec_prereq = Rails.configuration.generators.options[:rails][:orm] == :active_record ?  "db:test:prepare" : :noop
      t =RSpec::Core::RakeTask.new(spec_prereq).instance_eval do |i|
        self.pattern = ["./spec/common/**/*_spec.rb","./spec/#{app}/**/*_spec.rb"]
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