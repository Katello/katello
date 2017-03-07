require 'katello_test_helper'

module Katello
  class ActivationKeyTest < ActiveSupport::TestCase
    def setup
      @dev_key = ActivationKey.find(katello_activation_keys(:dev_key).id)
      @dev_staging_view_key = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key).id)
      @dev_view = ContentView.find(katello_content_views(:library_dev_view).id)
      @lib_view = ContentView.find(katello_content_views(:library_view).id)
    end

    test "can have content view" do
      @dev_key = ActivationKey.find(katello_activation_keys(:dev_key).id)
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
      org = Organization.find(taxonomies(:organization2))
      key = ActivationKey.find(katello_activation_keys(:simple_key).id)
      assert ActivationKey.new(:name => key.name, :organization => org).valid?
    end

    test "renamed key can be used again" do
      key1 = ActivationKey.find(katello_activation_keys(:simple_key).id)
      org = key1.organization
      original_name = key1.name
      key1.name = "new name"
      key1.save!
      assert ActivationKey.new(:name => original_name, :organization => org).valid?
    end

    test "key can be copied" do
      new_key = @dev_key.copy("new key name")
      assert_equal new_key.name, "new key name"
      assert_equal new_key.description, @dev_key.description
      assert_equal new_key.host_collections, @dev_key.host_collections
      assert_equal new_key.content_view, @dev_key.content_view
      assert_equal new_key.organization, @dev_key.organization
      assert_equal new_key.max_hosts, @dev_key.max_hosts
    end

    test "unlimited hosts requires no max hosts" do
      key1 = ActivationKey.find(katello_activation_keys(:simple_key).id)
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
      pool_one.subscription_id = nil
      pool_one.save!
      cp_pools = [{'id' => pool_one.cp_id}]

      @dev_key.stubs(:get_key_pools).returns(cp_pools)
      assert_empty @dev_key.products
    end

    def test_available_subscriptions
      pool_one = katello_pools(:pool_one)
      pool_two = katello_pools(:pool_two)
      fedora = katello_products(:fedora)
      pool_two.subscription.products.delete(fedora) # pool two no longer contains sub content
      cp_pools = [{'id' => 'abc123'}, {'id' => 'xyz123'}]

      @dev_key.stubs(:get_pools).returns(cp_pools)
      @dev_key.pools = []

      assert_equal [pool_one], @dev_key.available_subscriptions
    end
  end
end
