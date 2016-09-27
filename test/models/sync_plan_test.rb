require 'katello_test_helper'

module Katello
  class SyncPlanTest < ActiveSupport::TestCase
    def setup
      @organization = get_organization
      @plan = SyncPlan.new(:name => 'Norman Rockwell', :organization => @organization, :sync_date => DateTime.now, :interval => 'daily')
    end

    def test_invalid_intervals
      @plan.interval = 'notgood'
      @plan.wont_be :valid?
    end

    def test_modify_interval
      @plan.interval = 'weekly'
      @plan.must_be :valid?
    end

    def test_sync_date_future
      sync_date = '5000/11/17 18:26:48 UTC'
      @plan.sync_date = sync_date
      @plan.next_sync.to_s.must_equal(sync_date)
    end

    def sync_date_if_disabled
      @plan.sync_date = '1999-11-17 18:26:48 UTC'
      @plan.enabled = false
      @plan.next_sync.must_be_nil
    end

    def test_sync_date_if_bad_interval
      @plan.sync_date = '1999-11-17 18:26:48 UTC'
      @plan.interval = 'blah'
      @plan.next_sync.must_equal(nil)
    end

    def test_next_run_hourly
      @plan.interval = 'hourly'
      @plan.sync_date = '1999-11-17 09:26:00 UTC'

      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9))
      @plan.next_sync.must_equal(Time.new(2012, 1, 1, 9, 26, 0, "+00:00"))

      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9, 30))
      @plan.next_sync.must_equal(Time.new(2012, 1, 1, 10, 26, 0, "+00:00"))
    end

    def test_next_run_daily
      @plan.interval = 'daily'
      @plan.sync_date = '1999-11-17 09:26:00 UTC'

      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9))
      @plan.next_sync.must_equal(Time.new(2012, 1, 1, 9, 26, 0, "+00:00"))

      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9, 27))
      @plan.next_sync.must_equal(Time.new(2012, 1, 2, 9, 26, 0, "+00:00"))

      Time.stubs(:now).returns(Time.utc(2012, 1, 2, 9))
      @plan.next_sync.must_equal(Time.new(2012, 1, 2, 9, 26, 0, "+00:00"))
    end

    def test_next_run_weekly
      @plan.interval = 'weekly'
      @plan.sync_date = '1999-11-17 09:26:00 UTC'

      Time.stubs(:now).returns(Time.new(2012, 1, 1, 9))
      @plan.next_sync.must_equal(Time.new(2012, 1, 4, 9, 26, 0, "+00:00"))

      Time.stubs(:now).returns(Time.new(2012, 1, 11, 9, 30))
      @plan.next_sync.must_equal(Time.new(2012, 1, 18, 9, 26, 0, "+00:00"))
    end

    def test_update
      @plan.save!
      p = SyncPlan.find_by_name('Norman Rockwell')
      p.wont_be_nil
      new_name = p.name + "N"
      p = SyncPlan.update(p.id, :name => new_name)
      p.name.must_equal(new_name)
    end

    def test_delete
      @plan.save!
      p = SyncPlan.find_by_name('Norman Rockwell')
      pid = p.id
      p.destroy

      lambda { SyncPlan.find(pid) }.must_raise(ActiveRecord::RecordNotFound)
    end

    def test_schedule_format
      @plan.interval = 'weekly'
      @plan.sync_date = DateTime.now + 3.days

      schedule = @plan.schedule_format
      refute_nil schedule
      assert_match(/\/P7D$/, schedule)
      assert_includes schedule, @plan.sync_date.iso8601
    end

    def test_schedule_format_past_weekly
      @plan.interval = 'weekly'
      @plan.sync_date = DateTime.now - 3.days

      schedule = @plan.schedule_format
      refute_nil schedule
      assert_match(/\/P7D$/, schedule)
      assert_includes schedule, @plan.next_sync_date.iso8601
    end

    def test_schedule_format_past_daily
      @plan.interval = 'daily'
      @plan.sync_date = DateTime.now - 3.days

      schedule = @plan.schedule_format
      refute_nil schedule
      assert_match(/\/PT24H$/, schedule)
      assert_includes schedule, @plan.next_sync_date.iso8601
    end
  end
end
