require 'katello_test_helper'
require 'rake'

module Katello
  class ReimportTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/reimport'
      Rake::Task['katello:reimport'].reenable
      Rake::Task['katello:check_ping'].reenable
      Rake::Task.define_task(:environment)
    end

    def test_reimport_with_bad_ping
      Katello::Ping.expects(:ping).returns(:status => 'bad')
      assert_raises(RuntimeError) do
        Rake.application.invoke_task('katello:reimport')
      end
    end

    def test_reimport
      Katello::Ping.expects(:ping).returns(:status => 'ok')
      Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }

      importable_models = Katello::Model.subclasses.select { |model| model if model.respond_to?(:import_all) }
      importable_models.each { |model| model.expects(:import_all) }

      key = katello_activation_keys(:simple_key)
      key.expects(:import_pools)
      Katello::ActivationKey.stubs(:all).returns([key])

      Rake.application.invoke_task('katello:reimport')
    end
  end
end
