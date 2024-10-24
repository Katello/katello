require 'katello_test_helper'

module Katello
  class SyncPlanTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
    def setup
      @organization = get_organization
      @plan = SyncPlan.new(:name => 'Norman Rockwell', :organization => @organization, :sync_date => Time.now, :interval => 'daily')
      @plan_to_audit = SyncPlan.new(:name => 'Test Prod Sync', :organization => @organization, :sync_date => Time.now, :interval => 'daily')
    end

    def teardown
      SyncPlan.destroy_all
    end

    def valid_attributes
      {:name => 'Sync plan', :organization => @organization, :sync_date => Time.now, :interval => 'daily'}
    end

    # Returns a list of valid sync dates.
    def valid_sync_dates
      to_day = Time.now
      [
        to_day,
        to_day + 5.minutes,
        to_day + 5.days,
        to_day - 1.day,
        to_day - 5.minutes
      ]
    end

    # Returns a list of valid sync intervals.
    def valid_sync_intervals
      ["hourly", "daily", "weekly", "custom cron"]
    end

    test_attributes :pid => 'df5837e7-3d0f-464a-bd67-86b423c16eb4'
    def test_create_enabled_disabled
      [false, true].each do |enabled|
        sync_plan = SyncPlan.new(valid_attributes.merge(:name => enabled))
        assert sync_plan.valid?, "Validation failed when creating with enabled = #{enabled}"
        sync_plan.save_with_logic! enabled
        assert_equal enabled, sync_plan.enabled
      end
    end

    test_attributes :pid => 'c1263134-0d7c-425a-82fd-df5274e1f9ba'
    def test_create_with_name
      valid_name_list.each do |name|
        sync_plan = SyncPlan.new(valid_attributes.merge(:name => name))
        assert sync_plan.valid?, "Validation failed for create with valid name: '#{name}' length: #{name.length})"
        assert_equal name, sync_plan.name
      end
    end

    test_attributes :pid => '3e5745e8-838d-44a5-ad61-7e56829ad47c'
    def test_create_with_description
      valid_name_list.each do |description|
        sync_plan = SyncPlan.new(valid_attributes.merge(:description => description))
        assert sync_plan.valid?, "Validation failed for create with valid description: '#{description}' length: #{description.length})"
        assert_equal description, sync_plan.description
      end
    end

    test_attributes :pid => 'd160ed1c-b698-42dc-be0b-67ac693c7840'
    def test_create_with_interval
      valid_sync_intervals.each do |interval|
        sync_plan = SyncPlan.new(valid_attributes.merge(:interval => interval))
        assert sync_plan.valid?, "Validation failed for create with valid interval: '#{interval}'"
        assert_equal interval, sync_plan.interval
      end
    end

    test_attributes :pid => 'bdb6e0a9-0d3b-4811-83e2-2140b7bb62e3'
    def test_create_with_sync_date
      valid_sync_dates.each do |sync_date|
        sync_plan = SyncPlan.new(valid_attributes.merge(:sync_date => sync_date))
        assert sync_plan.valid?, "Validation failed for create with valid sync_date: '#{sync_date}'"
        assert_equal sync_date, sync_plan.sync_date
      end
    end

    test_attributes :pid => 'a3a0f844-2f81-4f87-9f68-c25506c29ce2'
    def test_create_with_invalid_name
      invalid_name_list.each do |name|
        sync_plan = SyncPlan.new(valid_attributes.merge(:name => name))
        refute sync_plan.valid?, "Validation succeed for create with invalid name: '#{name}' length: #{name.length})"
        assert_includes sync_plan.errors.attribute_names, :name
      end
    end

    test_attributes :pid => 'f5844526-9f58-4be3-8a96-3849a465fc02'
    def test_create_with_invalid_interval
      invalid_name_list.each do |interval|
        sync_plan = SyncPlan.new(valid_attributes.merge(:interval => interval))
        refute sync_plan.valid?, "Validation succeed for create with invalid interval: '#{interval}'"
        assert_includes sync_plan.errors.attribute_names, :interval
      end
    end

    def test_recurring_logic_on_create
      sync_plan = SyncPlan.new(valid_attributes)
      sync_plan.save_with_logic! true
      assert_not_equal sync_plan.foreman_tasks_recurring_logic, nil
      assert_equal sync_plan.foreman_tasks_recurring_logic.enabled?, sync_plan.enabled
    end

    test_attributes :pid => '325c0ef5-c0e8-4cb9-b85e-87eb7f42c2f8'
    def test_update_enabled
      @plan.save_with_logic!
      sync_plan_enabled = @plan.enabled
      [!sync_plan_enabled, sync_plan_enabled].each do |enabled|
        @plan.enabled = enabled
        assert @plan.save
      end
    end

    def test_destroy
      @plan.save_with_logic!
      @plan.foreman_tasks_recurring_logic.destroy!
      refute SyncPlan.find_by(id: @plan.id)
    end

    def test_invalid_cron_status
      @plan.cron_expression = "20 * * * *"
      refute @plan.valid?, "Custom cron expression only needs to be set for interval value of custom cron"
      @plan.save_with_logic!
      assert_equal @plan.cron_expression, ''
    end

    def test_nil_cron_status
      @plan.interval = 'custom cron'
      exception = assert_raises Exception do
        @plan.save_with_logic!
      end
      assert_equal('Cron expression is not valid!', exception.message)
    end

    test_attributes :pid => 'dbfadf4f-50af-4aa8-8d7d-43988dc4528f'
    def test_update_name
      @plan.save!
      valid_name_list.each do |name|
        @plan.name = name
        assert @plan.valid?, "Validation failed for update with valid name: '#{name}' length: #{name.length})"
        assert_equal name, @plan.name
      end
    end

    test_attributes :pid => '4769fe9c-9eec-40c8-b015-1e3d7e570bec'
    def test_update_description
      @plan.save!
      valid_name_list.each do |description|
        @plan.description = description
        assert @plan.valid?, "Validation failed for update with valid description: '#{description}' length: #{description.length})"
        assert_equal description, @plan.description
      end
    end

    test_attributes :pid => 'cf2eddf8-b4db-430e-a9b0-83c626b45068'
    def test_update_interval
      @plan.save_with_logic!
      # create a new valid list of intervals with the current interval in the last position
      intervals = valid_sync_intervals.reject { |interval| interval == @plan.interval }
      intervals << @plan.interval
      intervals.each do |interval|
        @plan.interval = interval
        assert @plan.save
        assert_equal interval, @plan.interval
      end
    end

    test_attributes :pid => 'fad472c7-01b4-453b-ae33-0845c9e0dfd4'
    def test_update_sync_date
      @plan.save_with_logic!
      valid_sync_dates.each do |sync_date|
        @plan.sync_date = sync_date
        assert_valid @plan
      end
    end

    test_attributes :pid => 'ae502053-9d3c-4cad-aee4-821f846ceae5'
    def test_update_with_invalid_name
      @plan.save!
      invalid_name_list.each do |name|
        @plan.name = name
        refute @plan.valid?, "Validation succeed for update with invalid name: '#{name}' length: #{name.length})"
        assert_includes @plan.errors.attribute_names, :name
      end
    end

    def test_cron_update_with_interval
      sync_plan = SyncPlan.new(valid_attributes.merge(:interval => "custom cron", :cron_expression => '* * * * *'))
      sync_plan.save_with_logic!
      sync_plan.reload
      assert_equal sync_plan.cron_expression, '* * * * *'
      params = {"interval": "daily"}.with_indifferent_access
      old_rec_logic_id = sync_plan.foreman_tasks_recurring_logic.id
      sync_plan.update_attributes_with_logics! params
      assert_equal sync_plan.cron_expression, ''
      assert_not_equal sync_plan.foreman_tasks_recurring_logic.id, old_rec_logic_id
    end

    def test_update_cron_without_interval
      sync_plan = SyncPlan.new(valid_attributes.merge(:interval => "custom cron", :cron_expression => '* * * * *'))
      sync_plan.save_with_logic!
      sync_plan.reload
      assert_equal sync_plan.cron_expression, '* * * * *'
      params = {"description": "Test updates without interval"}.with_indifferent_access
      old_rec_logic_id = sync_plan.foreman_tasks_recurring_logic.id
      sync_plan.update_attributes_with_logics! params
      assert_equal sync_plan.cron_expression, '* * * * *'
      assert_equal sync_plan.foreman_tasks_recurring_logic.id, old_rec_logic_id
    end

    def test_sync_date_future
      sync_date = '5000/11/17 18:26:48 +0000'
      @plan.sync_date = sync_date
      @plan.save_with_logic!
      assert_equal Time.utc(5000, 11, 18, 18, 26), @plan.next_sync
    end

    def sync_date_if_disabled
      @plan.sync_date = '1999-11-17 18:26:48 UTC'
      @plan.enabled = false
      refute @plan.next_sync
    end

    def test_sync_date_if_bad_interval
      @plan.sync_date = '1999-11-17 18:26:48 UTC'
      @plan.interval = 'blah'
      assert_raises(Exception) { @plan.save_with_logic! }
    end

    def test_next_run_hourly
      @plan.interval = 'hourly'
      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9))
      @plan.sync_date = '1999-11-17 09:26:00 UTC'
      @plan.save_with_logic!
      assert_equal Time.utc(2012, 1, 1, 9, 26), @plan.next_sync
    end

    def test_next_run_daily
      @plan.interval = 'daily'
      @plan.sync_date = '1999-11-17 09:26:00 UTC'
      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9))
      @plan.save_with_logic!
      assert_equal Time.utc(2012, 1, 1, 9, 26), @plan.next_sync
    end

    def test_next_run_weekly
      @plan.interval = 'weekly'
      @plan.sync_date = '1999-11-17 09:26:00 UTC' #WEDNESDAY
      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9))
      @plan.save_with_logic!
      assert_equal Time.utc(2012, 1, 4, 9, 26), @plan.next_sync # Wednesday
    end

    def test_next_run_cron_hourly
      @plan.interval = 'custom cron'
      @plan.sync_date = '1999-11-17 09:00:00 UTC'
      @plan.cron_expression = "10 * * * *" #Every hour at 10 minutes
      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9))
      @plan.save_with_logic!
      assert_equal Time.utc(2012, 1, 1, 9, 10), @plan.next_sync
    end

    def test_next_run_cron_daily_at_time
      @plan.interval = 'custom cron'
      @plan.sync_date = '1999-11-17 09:00:00 UTC'
      @plan.cron_expression = "5 10 * * *" #Everyday at 10:05  #
      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9))
      @plan.save_with_logic!
      assert_equal Time.utc(2012, 1, 1, 10, 5), @plan.next_sync
    end

    def test_next_run_cron_monthly
      @plan.interval = 'custom cron'
      @plan.sync_date = '1999-11-17 09:00:00 UTC'
      @plan.cron_expression = "15 14 5 * *" #At 14:15 on day-of-month 5
      Time.stubs(:now).returns(Time.utc(2012, 1, 1, 9))
      @plan.save_with_logic!
      assert_equal Time.utc(2012, 1, 5, 14, 15), @plan.next_sync
    end

    def test_next_run_weekly_week_prior_time_after_now
      @plan.interval = 'weekly'
      @plan.sync_date = '2012-11-10 09:26:00 UTC' #SATURDAY
      Time.stubs(:now).returns(Time.utc(2012, 11, 17, 9, 20))
      @plan.save_with_logic!
      assert_equal Time.utc(2012, 11, 17, 9, 26), @plan.next_sync
    end

    def test_invalid_custom_cron_expression
      @plan.interval = 'custom cron'
      @plan.sync_date = '1999-11-17 09:00:00 UTC'
      @plan.cron_expression = "15 5 5a * *" #Wrong Cron Expression
      exception = assert_raises Exception do
        @plan.save_with_logic!
      end
      assert_equal('Cron expression is not valid!', exception.message)
    end

    def test_update
      @plan.save!
      p = SyncPlan.find_by_name('Norman Rockwell')
      refute_nil p
      new_name = "#{p.name}N"
      p = SyncPlan.update(p.id, :name => new_name)
      assert_equal new_name, p.name
    end

    def test_delete
      sync_plan = SyncPlan.new(valid_attributes)
      sync_plan.save_with_logic! true
      p = SyncPlan.find_by_name('Sync plan')
      pid = p.id
      p.destroy

      assert_raises(ActiveRecord::RecordNotFound) { SyncPlan.find(pid) }
    end

    def test_product_enabled
      product = katello_products(:redhat)
      @plan.products << product
      assert(@plan.valid?, "Plan must be valid")
    end

    def test_remove_product
      product = katello_products(:redhat)
      @plan.products << product
      assert(@plan.valid?, "Plan must be valid")
      @plan.products.clear
      assert(@plan.valid?, "Plan must be valid")
    end

    def test_invalid_product_enabled
      product = katello_products(:empty_redhat)
      @plan.products << product
      refute(@plan.valid?, "Plan must be invalid")
      assert_includes(@plan.errors.full_messages, "Cannot add product #{product.name} because it is disabled.", "Validation should give proper error message")
    end

    def test_audit_creation_on_new_sync_plan
      assert_difference '@plan_to_audit.audits.count' do
        @plan_to_audit.save!
      end
    end

    def test_product_associated_audits
      product = katello_products(:redhat)
      @plan_to_audit.products << product
      assert_difference '@plan_to_audit.audits.count' do
        @plan_to_audit.save!
      end
    end

    def test_cancel_recurring_logic
      sync_plan = SyncPlan.new(valid_attributes)
      sync_plan.save_with_logic! true
      p = SyncPlan.find_by_name('Sync plan')
      p.cancel_recurring_logic
      assert_equal "cancelled", p.foreman_tasks_recurring_logic.state
    end

    def test_remove_disabled_product
      product = katello_products(:redhat)
      repository = product.repositories.first
      Product.any_instance.stubs(:repositories).returns([repository])
      @plan.products << product
      @plan.save!
      ::Katello::SyncPlan.remove_disabled_product(repository)
      product.reload
      assert_nil product.sync_plan
    end
  end
end
