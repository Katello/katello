require 'katello_test_helper'

module Katello
  class ActivationKeyTest < ActiveSupport::TestCase
    def setup
      @dev_key = ActivationKey.find(katello_activation_keys(:dev_key))
      @dev_staging_view_key = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key))
      @dev_view = ContentView.find(katello_content_views(:library_dev_view))
      @lib_view = ContentView.find(katello_content_views(:library_view))
    end

    test "can have content view" do
      @dev_key = ActivationKey.find(katello_activation_keys(:dev_key))
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
      key = ActivationKey.find(katello_activation_keys(:simple_key))
      assert ActivationKey.new(:name => key.name, :organization => org).valid?
    end

    test "renamed key can be used again" do
      key1 = ActivationKey.find(katello_activation_keys(:simple_key))
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
      assert_equal new_key.max_content_hosts, @dev_key.max_content_hosts
    end

    test "unlimited hosts requires no max hosts" do
      key1 = ActivationKey.find(katello_activation_keys(:simple_key))
      org = key1.organization
      new_key = ActivationKey.new(:name => "JarJar", :organization => org)
      new_key.unlimited_content_hosts = false
      new_key.max_content_hosts = 100
      assert new_key.valid?

      new_key.unlimited_content_hosts = true
      new_key.max_content_hosts = nil
      assert new_key.valid?

      new_key.max_content_hosts = 100
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

    def test_valid_content_label?
      @dev_key.stubs(:available_content).returns([OpenStruct.new(:content => OpenStruct.new(:label => 'some-label'))])
      assert @dev_key.valid_content_label?('some-label')
    end
  end
end
