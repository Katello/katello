# when mock receives unexpected message
# it adds line where mock was created to a message error
#    RSpec::Mocks::MockExpectationError: Mock "syncable" created on:
#     /.../spec/controllers/api/sync_controller_spec.rb:200 received unexpected message :sync with (no args)

require 'rspec/version'

unless RSpec::Version::STRING =~ /^2\.10\.0$/ # change if it works for other versions
  warn "monkey eats only a banana! (this monkey needs rspec 2.10.0)\n#{__FILE__}:#{__LINE__}"
else
  module RSpec::Mocks
    module TestDouble
      def initialize(name=nil, stubs_and_options={ })
        __initialize_as_test_double(name, stubs_and_options)
        @__created_on_line = caller.find { |line| line =~ %r(/spec/) }
      end
    end

    class ErrorGenerator
      def intro
        intro = if @name
                  "#{@declared_as} #{@name.inspect}"
                elsif TestDouble === @target
                  @declared_as
                elsif Class === @target
                  "<#{@target.inspect} (class)>"
                elsif @target
                  @target
                else
                  "nil"
                end
        if created_on_line = @target.instance_eval { @__created_on_line }
          "#{intro} created on: \n#{created_on_line}"
        else
          intro
        end
      end
    end
  end
end
