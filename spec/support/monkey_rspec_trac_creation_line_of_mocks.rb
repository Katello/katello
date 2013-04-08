#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

# when mock receives unexpected message
# it adds line where mock was created to a message error
#    RSpec::Mocks::MockExpectationError: Mock "syncable" created on:
#     /.../spec/controllers/api/sync_controller_spec.rb:200 received unexpected message :sync with (no args)

require 'rspec/rails/version'

version = begin
  RSpec::Version::STRING =~ /^2\.(\d+)\.\d+$/
  (5..10).include? $1.to_i
rescue
  false
end

unless version # change if it works for other versions
  warn "monkey eats only a banana! (this monkey needs rspec 2.(5-10))\n#{__FILE__}:#{__LINE__}"
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
