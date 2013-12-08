require 'ci/reporter/minitest'
require 'support/vcr'

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
      begin
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
    end

    def _run_suite(suite, type)
      begin
        User.current = nil #reset User.current
        suite.before_suite if suite.respond_to?(:before_suite)
        super(suite, type)
      ensure
        suite.after_suite if suite.respond_to?(:after_suite)
        ResourceTypeBackup.restore
      end
    end

  end
end

class ResourceTypeBackup
  @@types_backup = Katello::ResourceType::TYPES.clone

  def self.restore
    Katello::ResourceType::TYPES.clear
    Katello::ResourceType::TYPES.merge!(@@types_backup)
  end
end

MiniTest::Unit.runner = KatelloMiniTestRunner::Unit.new
