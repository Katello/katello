namespace "test" do
  ["katello", "headpin"].each do |app|
    desc "Invoke #{app} RSpec tests"
    task "#{app}_tests" do
      RSpec::Core::RakeTask.new.instance_eval do |i|
        self.pattern = ["./spec/common/*_spec.rb","./spec/#{app}/*_spec.rb"]
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
        end.invoke
      end
    end
  end
end