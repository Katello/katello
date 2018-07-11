require 'katello_test_helper'

module Katello
  class ActivationKeyTest < ActiveSupport::TestCase
    def setup
      @dev_key = katello_activation_keys(:dev_key)
      @dev_staging_view_key = katello_activation_keys(:library_dev_staging_view_key)
      @dev_view = katello_content_views(:library_dev_view)
      @lib_view = katello_content_views(:library_view)
      @pool_one = katello_pools(:pool_one)
    end

    should allow_values(*valid_name_list).for(:name)
    should allow_values(*valid_name_list).for(:description)
    should_not allow_values(-1, 0, 'foo').for(:max_hosts)

    test "can have content view" do
      @dev_key = katello_activation_keys(:dev_key)
      @dev_key.content_view = @dev_view
      assert @dev_key.save!
      assert_not_nil @dev_key.content_view
      assert_includes @dev_view.activation_keys, @dev_key
    end

    test "does not require a content view" do
      assert_nil @dev_key.content_view
      assert @dev_key.save!
      assert_nil @dev_key.content_view
    end

    test "content view must be in environment" do
      @dev_key.content_view = @lib_view
      refute @dev_key.save
      refute_empty @dev_key.errors.keys
      assert_raises(ActiveRecord::RecordInvalid) do
        @dev_key.save!
      end
    end

    test "same name can be used across organizations" do
      org = taxonomies(:organization2)
      key = katello_activation_keys(:simple_key)
      assert ActivationKey.new(:name => key.name, :organization => org).valid?
    end

    test "renamed key can be used again" do
      key1 = katello_activation_keys(:simple_key)
      org = key1.organization
      original_name = key1.name
      key1.name = "new name"
      key1.save!
      assert ActivationKey.new(:name => original_name, :organization => org).valid?
    end

    test "key can be copied" do
      new_key = @dev_key.copy("new key name")
      assert new_key.name == "new key name"
      assert new_key.description == @dev_key.description
      assert new_key.host_collections == @dev_key.host_collections
      assert new_key.content_view == @dev_key.content_view
      assert new_key.organization == @dev_key.organization
      assert new_key.max_hosts == @dev_key.max_hosts
    end

    test "unlimited hosts requires no max hosts" do
      key1 = katello_activation_keys(:simple_key)
      org = key1.organization
      new_key = ActivationKey.new(:name => "JarJar", :organization => org)
      new_key.unlimited_hosts = false
      new_key.max_hosts = 100
      assert new_key.valid?

      new_key.unlimited_hosts = true
      new_key.max_hosts = nil
      assert new_key.valid?

      new_key.max_hosts = 100
      assert !new_key.valid?
    end

    test "key can return pools" do
      assert @dev_key.pools.count > 0
    end

    test "audit creation on activation key" do
      org = Organization.find(taxonomies(:organization2).id)
      new_key = ActivationKey.new(:name => "ActKeyAudit", :organization => org)
      assert_difference 'new_key.audits.count' do
        new_key.save!
      end
    end

    test "audit creation on activation key deletion" do
      org = Organization.find(taxonomies(:organization2).id)
      new_key_to_delete = ActivationKey.new(:name => "ActKeyToDelete", :organization => org)
      new_key_to_delete.save!

      assert_difference 'Audit.count' do
        new_key_to_delete.destroy
      end
    end

    def test_search_name
      activation_keys = ActivationKey.search_for("name = \"#{@dev_staging_view_key.name}\"")
      assert_includes activation_keys, @dev_staging_view_key
    end

    def test_search_organization_id
      activation_keys = ActivationKey.search_for("organization_id = \"#{@dev_staging_view_key.organization.id}\"")
      assert_includes activation_keys, @dev_staging_view_key
    end

    def test_search_environment
      activation_keys = ActivationKey.search_for("environment = \"#{@dev_staging_view_key.environment.name}\"")
      assert_includes activation_keys, @dev_staging_view_key
    end

    def test_search_content_view
      activation_keys = ActivationKey.search_for("content_view = \"#{@dev_staging_view_key.content_view.name}\"")
      assert_includes activation_keys, @dev_staging_view_key
    end

    def test_search_content_view_id
      activation_keys = ActivationKey.search_for("content_view_id = \"#{@dev_staging_view_key.content_view.id}\"")
      assert_includes activation_keys, @dev_staging_view_key
    end

    def test_search_description
      activation_keys = ActivationKey.search_for("description = \"#{@dev_staging_view_key.description}\"")
      assert_includes activation_keys, @dev_staging_view_key
    end

    def test_search_subscription_id
      activation_keys = ActivationKey.search_for("subscription_id = \"#{@pool_one.id}\"")
      assert_includes activation_keys, @dev_key
    end

    def test_search_subscription_name
      activation_keys = ActivationKey.search_for("subscription_name = \"#{@pool_one.subscription.name}\"")
      assert_includes activation_keys, @dev_key
    end

    def test_valid_content_override_label?
      @dev_key.stubs(:available_content).returns([OpenStruct.new(:content => OpenStruct.new(:label => 'some-label'))])
      assert @dev_key.valid_content_override_label?('some-label')
    end

    def test_max_hosts_not_exceeded
      @dev_key.unlimited_hosts = false
      @dev_key.max_hosts = 1
      @dev_key.stubs(:subscription_facets).returns(['host one', 'host two'])
      refute @dev_key.valid?
    end

    def test_max_hosts_exceeded
      @dev_key.unlimited_hosts = false
      @dev_key.max_hosts = 10
      @dev_key.stubs(:subscription_facets).returns(['host one', 'host two'])
      assert @dev_key.valid?
    end

    def test_products
      pool_one = katello_pools(:pool_one)
      cp_pools = [{'id' => pool_one.cp_id}]

      @dev_key.stubs(:get_key_pools).returns(cp_pools)

      assert_equal pool_one.products, @dev_key.products
    end

    def test_available_subscriptions
      pool_one = katello_pools(:pool_one)
      pool_two = katello_pools(:pool_two)
      fedora = katello_products(:fedora)
      pool_two.products.delete(fedora) # pool two no longer contains sub content
      cp_pools = [{'id' => 'abc123'}, {'id' => 'xyz123'}]

      @dev_key.stubs(:get_pools).returns(cp_pools)
      @dev_key.pools = []

      assert_equal [pool_one, pool_two], @dev_key.available_subscriptions
    end

    context 'host_collection' do
      setup do
        @host_collection = katello_host_collections(:simple_host_collection)
        @sample_key = katello_activation_keys(:dev_key)
        @sample_key.host_collection_ids = [@host_collection.id]
        @sample_key.save!
      end

      test 'should audit when a host_collection is added to a activation_key' do
        recent_audit = @sample_key.audits.last
        audited_changes = recent_audit.audited_changes[:host_collection_ids]
        assert audited_changes, 'No audits found for activation_keys'
        assert_empty audited_changes.first
        assert_equal [@host_collection.id], audited_changes.last
      end
    end
  end
end
