require 'katello_test_helper'

module Katello
  module Tasks
    class Pulp3ContentSwitchoverTaskTest < ActiveSupport::TestCase
      def setup
        Rake.application.rake_require 'katello/tasks/pulp3_content_switchover'
        Rake::Task['katello:pulp3_content_switchover'].reenable
        Rake::Task.define_task(:environment)

        @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
        SETTINGS[:katello][:use_pulp_2_for_content_type] = {:file => true, :docker => true}
      end

      def teardown
        SETTINGS[:katello][:use_pulp_2_for_content_type] = {:file => false, :docker => false}
      end

      def test_run
        Katello::Pulp3::MigrationSwitchover.any_instance.expects(:run)
        Rake.application.invoke_task('katello:pulp3_content_switchover')
      end
    end
  end
end
