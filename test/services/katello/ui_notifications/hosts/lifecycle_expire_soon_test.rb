require 'katello_test_helper'

# 'RHEL9' => {
#   'maintenance_support' => end_of_day('2032-05-31'),
#   'extended_support' => end_of_day('2035-05-31')
# },
# 'RHEL8' => {
#   'maintenance_support' => end_of_day('2029-05-31'),
#   'extended_support' => end_of_day('2032-05-31')
# },
# 'RHEL7' => {
#   'maintenance_support' => end_of_day('2024-06-30'),
#   'extended_support' => end_of_day('2028-06-30')
# },
# 'RHEL6' => {
#   'maintenance_support' => end_of_day('2020-11-30'),
#   'extended_support' => end_of_day('2024-06-30')
# },

module Katello
  module UINotifications
    module Hosts
      class LifecycleExpireSoonTest < ::ActiveSupport::TestCase
        def setup
          blueprint = FactoryBot.create(:notification_blueprint, :name => 'host_lifecycle_expire_soon')
          @subject = Katello::UINotifications::Hosts::LifecycleExpireSoon
          @subject.stubs(:blueprint).returns(blueprint)
        end

        def teardown
          NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.destroy_all
        end

        def test_with_year_2024_1_1
          Time.stubs(:now).returns(Time.utc(2024, 1, 1))
          @subject.expects(:hosts_with_index).with("RHEL6").returns([mock('rhel6')])
          @subject.expects(:hosts_with_index).with("RHEL7").returns([mock('rhel7')])
          @subject.deliver!
          assert_equal 2, NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.count
        end

        def test_with_year_2025_1_1
          Time.stubs(:now).returns(Time.utc(2025, 1, 1))
          @subject.deliver!
          assert_equal 0, NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.count
        end

        def test_with_year_2026_6_1
          Time.stubs(:now).returns(Time.utc(2026, 6, 1))
          @subject.deliver!
          assert_equal 0, NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.count
        end

        def test_with_year_2027_7_1
          Time.stubs(:now).returns(Time.utc(2027, 7, 1))
          @subject.expects(:hosts_with_index).with("RHEL7").returns([mock('rhel7')])
          @subject.deliver!
          assert_equal 1, NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.count
        end

        def test_with_year_2028_6_1
          Time.stubs(:now).returns(Time.utc(2028, 6, 1))
          @subject.expects(:hosts_with_index).with("RHEL7").returns([mock('rhel7')])
          @subject.expects(:hosts_with_index).with("RHEL8").returns([mock('rhel8')])
          @subject.deliver!
          assert_equal 2, NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.count
        end

        def test_with_year_2029_6_1
          Time.stubs(:now).returns(Time.utc(2029, 6, 1))
          @subject.deliver!
          assert_equal 0, NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.count
        end

        def test_with_year_2030_6_1
          Time.stubs(:now).returns(Time.utc(2030, 6, 1))
          @subject.deliver!
          assert_equal 0, NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.count
        end

        def test_with_year_2031_6_1
          Time.stubs(:now).returns(Time.utc(2031, 6, 1))
          @subject.expects(:hosts_with_index).with("RHEL8").returns([mock('rhel8')])
          @subject.expects(:hosts_with_index).with("RHEL9").returns([mock('rhel9')])
          @subject.deliver!
          assert_equal 2, NotificationBlueprint.find_by(name: 'host_lifecycle_expire_soon').notifications.count
        end
      end
    end
  end
end
