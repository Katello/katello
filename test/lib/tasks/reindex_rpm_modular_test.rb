require 'katello_test_helper'
require 'rake'

module Katello
  class ReindexRpmModularTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/3.15/reindex_rpm_modular'
      Rake::Task['katello:upgrades:3.15:reindex_rpm_modular'].reenable
      Rake::Task.define_task(:environment)
    end

    def test_package_reindexing
      modular = ::Katello::Rpm.modular.first
      non_modular = ::Katello::Rpm.non_modular.first
      #reverse the modular settings for is_modular
      pulp_response = [
        {"_id": non_modular.pulp_id}
      ].map(&:with_indifferent_access)
      mock_pulp(pulp_response)
      Rake.application.invoke_task('katello:upgrades:3.15:reindex_rpm_modular')

      refute ::Katello::Rpm.find(modular.id).reload.modular?
      assert ::Katello::Rpm.find(non_modular.id).reload.modular?
    end

    def mock_pulp(value = [])
      rpm = mock(:content_type => "rpm")
      extensions = mock(:rpm => rpm)

      unit = mock
      unit.stubs(:search).returns(value, [])

      resources = stub(:unit => unit)
      pulp_server = stub(:resources => resources, :extensions => extensions)
      Katello.stubs(:pulp_server).returns(pulp_server)
    end
  end
end
