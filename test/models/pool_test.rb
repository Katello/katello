require 'katello_test_helper'

module Katello
  class PoolTest < ActiveSupport::TestCase
    def setup
      @library = katello_environments(:library)
      @view = katello_content_views(:library_dev_view)
      @pool_one = katello_pools(:pool_one)
      @pool_two = katello_pools(:pool_two)
      @custom_pool = katello_pools(:custom_pool)
      @host_one = hosts(:one)
    end

    def test_upstream
      assert @pool_one.upstream?
      refute @custom_pool.upstream?
    end

    def test_active
      active_pool = FactoryBot.build(:katello_pool, :active)
      inactive_pool = FactoryBot.build(:katello_pool, :inactive)
      all_subscriptions = [active_pool, inactive_pool]
      active_subscriptions = all_subscriptions.select(&:active?)
      assert_equal active_subscriptions, all_subscriptions - [inactive_pool]
    end

    def test_expiring_soon
      not_expiring_soon = FactoryBot.build(:katello_pool, :not_expiring_soon)
      expiring_soon_pool = FactoryBot.build(:katello_pool, :expiring_soon)
      all_subscriptions = [not_expiring_soon, expiring_soon_pool]
      expiring_soon_subscriptions = all_subscriptions.select(&:expiring_soon?)
      assert_equal expiring_soon_subscriptions, all_subscriptions - [not_expiring_soon]
    end

    def test_days_until_expiration
      expiring_pool = FactoryBot.build(:katello_pool, :expiring_in_12_days)
      assert_equal expiring_pool.days_until_expiration, 12
    end

    def test_stacking_id
      assert_equal @pool_one.subscription, Pool.stacking_subscription(@pool_one.organization.label, @pool_one.subscription.cp_id)
    end

    def test_stacking_id_no_match
      ::Katello::Resources::Candlepin::Product.expects(:find_for_stacking_id).with(@pool_one.organization.label, 'fake_stack').returns('id' => @pool_two.subscription.cp_id)
      assert_equal @pool_two.subscription, Pool.stacking_subscription(@pool_one.organization.label, 'fake_stack')
    end

    def test_recently_expired
      unexpired = FactoryBot.build(:katello_pool, :unexpired)
      recently_expired = FactoryBot.build(:katello_pool, :recently_expired)
      all_subscriptions = [unexpired, recently_expired]
      expired_subscriptions = all_subscriptions.select(&:recently_expired?)
      assert_equal expired_subscriptions, all_subscriptions - [unexpired]
    end

    def test_recently_expired_does_not_get_long_expired_subscriptions
      unexpired = FactoryBot.build(:katello_pool, :unexpired)
      recently_expired = FactoryBot.build(:katello_pool, :recently_expired)
      long_expired = FactoryBot.build(:katello_pool, :long_expired)

      all_subscriptions = [unexpired, recently_expired, long_expired]
      expired_subscriptions = all_subscriptions.select(&:recently_expired?)
      assert_equal expired_subscriptions, all_subscriptions - [unexpired, long_expired]
    end

    def test_with_identifiers
      assert_equal Pool.with_identifiers("#{@pool_one.cp_id}").first, @pool_one
      assert_equal Pool.with_identifiers("#{@pool_one.id}").first, @pool_one

      assert_equal Pool.with_identifier("#{@pool_one.cp_id}"), @pool_one
      assert_equal Pool.with_identifier("#{@pool_one.id}"), @pool_one
    end

    def test_hosts
      assert_equal @pool_one.hosts, [@host_one]
    end

    def test_hypervisors
      assert_equal @pool_one.hypervisor, @host_one
    end

    def test_search_consumed
      subscriptions = Pool.search_for("consumed = \"#{@pool_one.consumed}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_contract
      subscriptions = Pool.search_for("contract = \"#{@pool_one.contract_number}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_account
      subscriptions = Pool.search_for("account = \"#{@pool_one.account_number}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_quantity_available
      assert_equal @pool_one.quantity_available, 9
    end

    def test_import_all_default
      org = get_organization
      Pool.expects(:import_candlepin_ids).with(org).returns([@pool_one.cp_id])
      Pool.expects(:in_organization).with(org).returns([@pool_one])
      @pool_one.expects(:import_data).once
      @pool_one.expects(:import_managed_associations).once
      Pool.import_all(org)
    end

    def test_import_all_no_managed_association
      org = get_organization
      Pool.expects(:import_candlepin_ids).with(org).returns([@pool_one.cp_id])
      Pool.expects(:in_organization).with(org).returns([@pool_one])
      @pool_one.expects(:import_data).once
      @pool_one.expects(:import_managed_associations).never
      Pool.import_all(org, false)
    end

    def test_import_all_destroy
      org = get_organization
      Pool.expects(:import_candlepin_ids).with(org).returns([])
      Pool.expects(:in_organization).with(org).returns([@pool_one])
      Pool.import_all(org)
      refute Pool.find_by_id(@pool_one.id)
    end

    def test_import_hosts
      host = FactoryBot.create(:host, :with_subscription)
      Resources::Candlepin::Pool.expects(:consumer_uuids).returns([host.subscription_facet.uuid])

      @pool_one.import_hosts

      assert @pool_one.subscription_facets.where(id: host.subscription_facet.id).any?
    end

    def test_quantity_available_unlimited
      pool = FactoryBot.build(:katello_pool, quantity: -1, consumed: 3)
      assert_equal(-1, pool.quantity_available)
    end

    def test_search_cores
      subscriptions = Pool.search_for("cores = \"#{@pool_one.subscription.cores}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_expires
      subscriptions = Pool.search_for("expires = \"#{@pool_one.end_date}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_id
      subscriptions = Pool.search_for("id = \"#{@pool_one.cp_id}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_upstream_id
      subscriptions = Pool.search_for("upstream_pool_id = \"#{@pool_one.upstream_pool_id}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_instance_multiplier
      subscriptions = Pool.search_for("instance_multiplier = \"#{@pool_one.instance_multiplier}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_multi_entitlement
      subscriptions = Pool.search_for("multi_entitlement = \"#{@pool_one.multi_entitlement}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_name
      subscriptions = Pool.search_for("name = \"#{@pool_one.subscription.name}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_product_id
      subscriptions = Pool.search_for("product_id = \"#{@pool_one.subscription.cp_id}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_quantity
      subscriptions = Pool.search_for("quantity = \"#{@pool_one.quantity}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_ram
      subscriptions = Pool.search_for("ram = \"#{@pool_one.ram}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_sockets
      subscriptions = Pool.search_for("sockets = \"#{@pool_one.subscription.sockets}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_stacking_id
      subscriptions = Pool.search_for("stacking_id = \"#{@pool_one.stacking_id}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_starts
      subscriptions = Pool.search_for("starts = \"#{@pool_one.start_date}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_support_level
      subscriptions = Pool.search_for("support_level = \"#{@pool_one.support_level}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_virt_who
      subscriptions = Pool.search_for("virt_who = true")
      assert_includes subscriptions, @pool_one
    end

    def test_for_activation_key
      key = katello_activation_keys(:simple_key)
      key.pools << @pool_one
      assert_includes Pool.for_activation_key(key), @pool_one
    end

    def test_audit_hook_to_find_records_should_return_hosts
      # Note - creating audit record manually
      pool_host_ids = @pool_one.hosts.map(&:id)
      @pool_one.import_audit_record([], pool_host_ids)
      audit_record = Audited::Audit.find_by(:auditable_id => @pool_one.id, :auditable_type => 'Katello::Pool')

      refute_nil audit_record
      hosts_list = Katello::Pool.audit_hook_to_find_records('host_ids', audit_record.audited_changes['host_ids'][1], audit_record)

      assert_equal pool_host_ids.length, hosts_list.keys.length
    end
  end
end
