require 'katello_test_helper'

module Katello
  class ActivationKeyTest < ActiveSupport::TestCase
    def setup
      @dev_key = katello_activation_keys(:dev_key)
      @dev_staging_view_key = katello_activation_keys(:library_dev_staging_view_key)
      @dev_staging_cve = katello_content_view_environments(:library_dev_staging_view_dev)

      @dev_view = katello_content_views(:library_dev_view)
      @lib_view = katello_content_views(:library_view)
      @pool_one = katello_pools(:pool_one)
      @purpose_key = katello_activation_keys(:purpose_attributes_key)
    end

    should allow_values(*valid_name_list.map { |name| name.gsub(',', '') }).for(:name)
    should_not allow_values('name,with,commas').for(:name)
    should allow_values(*valid_name_list).for(:description)
    should_not allow_values(-1, 0, 'foo').for(:max_hosts)

    test "can have content view environment" do
      @dev_key = katello_activation_keys(:dev_key)
      @dev_key.content_view_environments = [@dev_staging_cve]
      assert @dev_key.save!
      assert_not_nil @dev_key.single_content_view
      assert_includes @dev_staging_cve.content_view.activation_keys, @dev_key
    end

    test "does not require a content view environment" do
      assert @dev_key.update(content_view_environments: [])
      assert_nil @dev_key.single_content_view
    end

    test "content view environment must be in the same org" do
      library_dev_staging_cve = katello_content_view_environments(:library_dev_staging_view_dev)
      org2 = taxonomies(:organization2)
      ak = ActivationKey.create!(name: 'new_key', organization: org2)
      ak.content_view_environments << library_dev_staging_cve
      refute ak.save
      refute_empty ak.errors.attribute_names
      assert_raises(ActiveRecord::RecordInvalid) do
        ak.save!
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
      @dev_key.max_hosts = 200
      new_key = @dev_key.copy("new key name")
      assert_equal new_key.name, "new key name"
      assert_equal new_key.description, @dev_key.description
      assert_equal new_key.host_collections, @dev_key.host_collections
      assert_equal new_key.content_view_environments, @dev_key.content_view_environments
      assert_equal new_key.organization, @dev_key.organization
      assert_equal new_key.max_hosts, @dev_key.max_hosts
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
      refute new_key.valid?
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

    def test_search_subscription_id_handles_non_integer
      assert_raises ScopedSearch::QueryNotSupported do
        ActivationKey.search_for("subscription_id = \"notaninteger\"")
      end
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

    def test_hosts_mapping
      total_hosts = hosts
      assert_equal 6, total_hosts.count
    end

    def test_products
      pool_one = katello_pools(:pool_one)
      cp_pools = [{'id' => pool_one.cp_id}]

      @dev_key.stubs(:get_key_pools).returns(cp_pools)

      assert_equal pool_one.products.sort, @dev_key.products.sort
    end

    def test_available_subscriptions
      pool_one = katello_pools(:pool_one)
      pool_two = katello_pools(:pool_two)
      fedora = katello_products(:fedora)
      pool_two.products.delete(fedora) # pool two no longer contains sub content
      cp_pools = [{'id' => 'abc123'}, {'id' => 'xyz123'}]

      @dev_key.stubs(:get_pools).returns(cp_pools)
      @dev_key.pools = []

      assert_includes @dev_key.available_subscriptions, pool_one
      assert_includes @dev_key.available_subscriptions, pool_two
      assert_equal @dev_key.available_subscriptions.length, 2
    end

    def test_search_role
      activation_keys = ActivationKey.search_for("role = \"#{@purpose_key.purpose_role}\"")
      assert_includes activation_keys, @purpose_key
    end

    def test_search_addon
      @purpose_key.purpose_addons << katello_purpose_addons(:addon)
      activation_keys = ActivationKey.search_for("addon = \"Test Addon\"")
      assert_includes activation_keys, @purpose_key
    end

    def test_search_usage
      activation_keys = ActivationKey.search_for("usage = \"#{@purpose_key.purpose_usage}\"")
      assert_includes activation_keys, @purpose_key
    end

    def test_destroy
      hg = hostgroups(:common)
      hg.group_parameters.create!(name: "kt_activation_keys", value: @dev_key.name)
      exception = assert_raises(RuntimeError) do
        @dev_key.validate_destroyable!
      end
      assert_match(/Search and unassociate Hosts\/Hostgroups using params.kt_activation_keys/, exception.message)
      hg.group_parameters.destroy_all
      assert @dev_key.validate_destroyable!
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
        audited_changes = recent_audit.audited_changes['host_collection_ids']
        assert audited_changes, 'No audits found for activation_keys'
        assert_empty audited_changes.first
        assert_equal [@host_collection.id], audited_changes.last
      end
    end
  end
end
