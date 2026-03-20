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
      @organization = @pool_one.organization
    end

    def test_upstream
      assert @pool_one.upstream?
      refute @custom_pool.upstream?
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
      assert_equal @pool_one.subscription, Pool.stacking_subscription(@pool_one.organization, @pool_one.subscription.cp_id)
    end

    def test_stacking_id_no_match
      ::Katello::Resources::Candlepin::Product.expects(:find_for_stacking_id).with(@pool_one.organization.label, 'fake_stack').returns('id' => @pool_two.subscription.cp_id)
      assert_equal @pool_two.subscription, Pool.stacking_subscription(@pool_one.organization, 'fake_stack')
    end

    def test_with_identifiers
      assert_equal Pool.with_identifiers("#{@pool_one.cp_id}").first, @pool_one
      assert_equal Pool.with_identifiers("#{@pool_one.id}").first, @pool_one

      assert_equal Pool.with_identifier("#{@pool_one.cp_id}"), @pool_one
      assert_equal Pool.with_identifier("#{@pool_one.id}"), @pool_one
    end

    def test_hypervisors
      assert_equal @pool_one.hypervisor, @host_one
    end

    def test_search_contract
      subscriptions = Pool.search_for("contract = \"#{@pool_one.contract_number}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_search_account
      subscriptions = Pool.search_for("account = \"#{@pool_one.account_number}\"")
      assert_includes subscriptions, @pool_one
    end

    def test_import_all_default
      org = get_organization
      Pool.expects(:candlepin_records_by_id).returns(
        {
          @pool_one.cp_id => {
            'productId' => @pool_one.subscription.cp_id,
            'id' => @pool_one.cp_id,
          },
        }
      )
      Pool.expects(:in_organization).with(org).returns([@pool_one])
      @pool_one.expects(:import_data).once
      Pool.import_all(org)
    end

    def test_import_all_new_record
      org = FactoryBot.create(:organization)
      pool_data = {
        'id' => 'abcd',
        'productId' => 'SKU001',
        'productAttributes' => [],
        'attributes' => [],
        'providedProducts' => [],
        'derivedProvidedProducts' => [],
        'owner' => {
          'key' => org.label,
        },
      }.with_indifferent_access

      FactoryBot.create(:katello_subscription, cp_id: 'SKU001', organization: org)
      Katello::Resources::Candlepin::Pool.expects(:get_for_owner).returns([pool_data])
      Katello::Resources::Candlepin::Pool.expects(:find).returns(pool_data)
      Organization.any_instance.expects(:redhat_provider).returns(katello_providers(:redhat))
      Pool.import_all(org)

      refute_empty Katello::Pool.where(organization: org)
    end

    CP_POOL_FIXTURE =
      {"accountNumber" => "5292024",
       "activeSubscription" => true,
       "attributes" => [
         {"name" => "unmapped_guests_only", "value" => "true"},
         {"name" => "requires_host", "value" => "some_consumer_cp_id"},
       ],
       "contractNumber" => "1212121",
       "derivedProductAttributes" => [],
       "derivedProductId" => nil,
       "derivedProductName" => nil,
       "derivedProvidedProducts" => [],
       "endDate" => "2026-04-26T03:59:59+0000",
       "href" => "/pools/4028fc849ca8236f019caab9a1452bbd",
       "id" => "4028fc849ca8236f019caab9a1452bbd",
       "managed" => true,
       "orderNumber" => nil,
       "owner" => {"anonymous" => false, "contentAccessMode" => "org_environment", "displayName" => "ImportOrg", "href" => "/owners/ImportOrg", "id" => "4028fc849c81693c019c82573a700014", "key" => "ImportOrg"},
       "productAttributes" =>
         [{"name" => "description", "value" => "Red Hat Enterprise Linux"},
          {"name" => "support_type", "value" => "L1-L3"},
          {"name" => "support_level", "value" => "Self-Support"},
          {"name" => "service_type", "value" => "Self-Support"},
          {"name" => "multi-entitlement", "value" => "yes"},
          {"name" => "virt_only", "value" => "true"},
          {"name" => "virt_limit", "value" => "1"},
          {"name" => "name", "value" => "Red Hat Beta Access"},
          {"name" => "roles", "value" => "TestRole"},
          {"name" => "ram", "value" => "128"},
          {"name" => "usage", "value" => "Development"},
          {"name" => "arch", "value" => "aarch64"}],
       "productId" => "RH00069",
       "productName" => "Red Hat Beta Access",
       "providedProducts" =>
        [{"productId" => "258", "productName" => "Red Hat Satellite Capsule Beta"},
         {"productId" => "555", "productName" => "Red Hat Enterprise Linux for SAP Applications for IBM z Systems Beta"}],
       "quantity" => 1,
       "sourceEntitlement" => nil,
       "sourceStackId" => nil,
       "stackId" => 'FakeStackId',
       "stacked" => false,
       "startDate" => "2025-04-26T04:00:00+0000",
       "subscriptionId" => "e701d80c3e8a48ecb6e2f7c42324cf13",
       "subscriptionSubKey" => "master",
       "type" => "NORMAL",
       "updated" => "2026-03-01T18:46:58+0000",
       "upstreamEntitlementId" => "c3b564a20c804616b0666d50fc2a1268",
       "upstreamPoolId" => "2c94e31e96694f32019674e3675916b9"}.with_indifferent_access

    def test_import_data
      pool = build(:katello_pool)
      pool.stubs(:backend_data).returns(CP_POOL_FIXTURE)
      pool.import_data

      assert_equal 5_292_024, pool.account_number
      assert_equal 1_212_121, pool.contract_number
      assert_equal 1, pool.quantity
      assert_equal 128, pool.ram
      assert_equal DateTime.parse(CP_POOL_FIXTURE['startDate']), pool.start_date
      assert_equal DateTime.parse(CP_POOL_FIXTURE['endDate']), pool.end_date
      assert_equal '2c94e31e96694f32019674e3675916b9', pool.upstream_pool_id
      assert_equal 'c3b564a20c804616b0666d50fc2a1268', pool.upstream_entitlement_id
      assert_equal 'L1-L3', pool.support_type
      assert_equal 'TestRole', pool.roles
      assert_equal 'Development', pool.usage
      assert_equal 'Red Hat Enterprise Linux', pool.description
      assert pool.multi_entitlement
      assert pool.virt_only
      assert_equal 'FakeStackId', pool.stacking_id
      assert_equal 'aarch64', pool.arch
      assert pool.virt_who
      assert pool.unmapped_guest
      assert_nil pool.hypervisor_id
    end

    def test_import_all_destroy
      org = get_organization
      Katello::Resources::Candlepin::Pool.expects(:get_for_owner).returns([])
      Pool.expects(:in_organization).with(org).returns([@pool_one])
      Pool.import_all(org)
      refute Pool.find_by_id(@pool_one.id)
    end

    def test_import_pool
      Pool.expects(:candlepin_data).returns({
        'id' => 'abcd',
        'productId' => 'SKU001',
        'productAttributes' => [],
        'attributes' => [],
        'providedProducts' => [],
        'derivedProvidedProducts' => [],
        'owner' => {
          'key' => @organization.label,
        }}.with_indifferent_access
      )

      subscription = FactoryBot.create(:katello_subscription, organization: @organization, cp_id: 'SKU001')

      Pool.import_pool('abcd')

      pool = Pool.find_by_cp_id('abcd')
      assert_equal @organization, pool.organization
      assert_equal subscription, pool.subscription
    end

    def test_import_pool_no_subscription
      Pool.expects(:candlepin_data).returns(
        'id' => 'abcd',
        'productAttributes' => [],
        'attributes' => [],
        'providedProducts' => [],
        'derivedProvidedProducts' => [],
        'owner' => {
          'key' => @organization.label,
        }
      )

      assert_raises(ActiveRecord::RecordInvalid) do
        Pool.import_pool('abcd')
      end
    end

    def test_import_pool_not_in_candlepin
      Pool.expects(:candlepin_data).raises(Katello::Errors::CandlepinPoolGone)

      assert_raises(Katello::Errors::CandlepinPoolGone) do
        Pool.import_pool('abcd')
      end
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

    def test_product_host_count
      product1 = katello_products(:product_host_count)
      product1.pools << @pool_one
      product1.pools << @pool_two
      repo1 = katello_repositories(:product_host_count_repo1)
      repo2 = katello_repositories(:product_host_count_repo2)
      repo1.product = product1
      repo2.product = product1
      content_facet1 = katello_content_facets(:content_facet_one)
      content_facet2 = katello_content_facets(:content_facet_two)

      # test if both hosts are counted correctly
      content_facet1.bound_repositories = [repo1]
      content_facet2.bound_repositories = [repo1]
      assert_equal 2, @pool_one.product_host_count

      # test if multiple repositories in one product are counted only as one
      content_facet2.bound_repositories = [repo1, repo2]
      assert_equal 2, @pool_one.product_host_count
    end
  end
end
