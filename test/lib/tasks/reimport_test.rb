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

      SmartProxy.stubs(:pulp_primary).returns(FactoryBot.create(:smart_proxy, :default_smart_proxy))
      Rake.application.invoke_task('katello:reimport')
    end

    def test_reimport_ignores_pulp3_content_types
      Katello::Ping.expects(:ping).returns(:status => 'ok')
      Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }
      Katello::ActivationKey.stubs(:all).returns([])
      SmartProxy.stubs(:pulp_primary).returns(FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3))

      ignore_content_types = []

      Katello::RepositoryTypeManager.repository_types.each_value do |repo_type|
        indexable_types = repo_type.content_types.select { |c| c.index }
        if SmartProxy.pulp_primary.pulp3_repository_type_support?(repo_type)
          ignore_content_types += indexable_types&.map { |type| type.model_class }
        end
      end
      assert_not_equal ignore_content_types.size, 0
      importable_models = Katello::Model.subclasses.select { |model| model if model.respond_to?(:import_all) }
      (importable_models - ignore_content_types).each { |model| model.expects(:import_all) }
      ignore_content_types.each { |model| model.expects(:import_all).never }
      Rake.application.invoke_task('katello:reimport')
    end
  end
end
