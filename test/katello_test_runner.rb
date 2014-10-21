require 'ci/reporter/minitest'
require File.expand_path("support/vcr", File.dirname(__FILE__))

module KatelloMiniTestRunner
  class Unit < CI::Reporter::Runner

    def before_suites
      # code to run before the first test
      configure_vcr
    end

    def after_suites
      # code to run after the last test
    end

    def _run_suites(suites, type)
      if ENV['suite']
        suites = suites.select do |suite|
          suite.name == ENV['suite']
        end
      end
      before_suites
      super(suites, type)
    ensure
      after_suites
    end

    def _run_suite(suite, type)
      User.current = nil  #reset User.current
      puts suite
      suite.before_suite if suite.respond_to?(:before_suite)
      super(suite, type)
    ensure
      suite.after_suite if suite.respond_to?(:after_suite)
      restore_glue_layers
    end

  end
end

MiniTest::Unit.runner = KatelloMiniTestRunner::Unit.new
