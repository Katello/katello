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
  const  = if defined? RSpec::Version::STRING
             RSpec::Version::STRING
           else
             RSpec::Core::Version::STRING
           end
  version = const.split('.').map &:to_i
  version[0] == 2 && (5..13).include?(version[1])
rescue
  false
end

unless version # change if it works for other versions
  warn "monkey eats only a banana! (this monkey needs rspec 2.(5-13))\n#{__FILE__}:#{__LINE__}"
else
  module RSpec::Mocks
    module TestDouble
      def initialize(name=nil, stubs_and_options={})
        __initialize_as_test_double(name, stubs_and_options)
        @__created_on_line = caller.find { |line| line =~ %r(/spec/) }
      end
    end

    class ErrorGenerator
      alias_method :intro_without_crated_on, :intro

      private

      def intro
        if created_on_line = @target.instance_eval { @__created_on_line }
          "#{intro_without_crated_on} created on: \n#{created_on_line}"
        else
          intro_without_crated_on
        end
      end
    end
  end
end
