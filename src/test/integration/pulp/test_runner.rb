# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rubygems'
require 'minitest/unit'
require 'minitest/autorun'
require './test/integration/pulp/vcr_pulp_setup'


class PulpMiniTestRunner
  class Unit < MiniTest::Unit

    def before_suites
      # code to run before the first test
    end

    def after_suites
      # code to run after the last test
    end

    def _run_suites(suites, type)
      begin
        before_suites
        super(suites, type)
      ensure
        after_suites
      end
    end

    def _run_suite(suite, type)
      begin
        suite.before_suite if suite.respond_to?(:before_suite)
        super(suite, type)
      ensure
        suite.after_suite if suite.respond_to?(:after_suite)
      end
    end

  end
end

MiniTest::Unit.runner = PulpMiniTestRunner::Unit.new


if ARGV.include?('--live')
  ARGV.delete('--live')
  configure_vcr(:all)
else
  configure_vcr(:new_episodes)
end

if ARGV.length > 0
  ARGV.each do|test_suite_name|
    require "test/integration/pulp/pulp_#{test_suite_name}_test.rb"
  end
else
  Dir["test/integration/pulp/*_test.rb"].each {|file| require file }
end
