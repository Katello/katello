require 'katello_test_helper'
require 'support/host_support'

module Katello
  class HostgroupExtensionsTest < ActiveSupport::TestCase
    def setup
      @view = ContentView.find(katello_content_views(:library_dev_staging_view).id)
      @library = KTEnvironment.find(katello_environments(:library).id)
      @dev = KTEnvironment.find(katello_environments(:dev).id)

      @root = Hostgroup.create!(:name => 'AHostgroup')
      @child = Hostgroup.create!(:name => 'AChild', :parent => @root)
      @puppet_env = smart_proxies(:puppetmaster)
    end

    def test_create_with_content_source
      content_source = smart_proxies(:four)
      host_group = Hostgroup.new(:name => 'new_hostgroup', :content_source => content_source)
      assert_valid host_group
      assert_equal content_source, host_group.content_source
    end

    def test_update_content_source
      content_source = smart_proxies(:four)
      host_group = Hostgroup.create!(:name => 'new_hostgroup')
      host_group.content_source = content_source
      assert_valid host_group
      assert_equal content_source, host_group.content_source
    end

    def inherited_content_source_id_with_ancestry
      @root.content_source =
        @root.save!

      assert_equal @puppet_env, @child.content_source
      assert_equal @puppet_env, @root.content_source
    end

    def test_add_organization_for_environment
      @root.lifecycle_environment = @library
      @root.save!

      assert_includes @root.organizations, @library.organization
    end

    def test_inherited_lifecycle_environment_with_ancestry
      @root.lifecycle_environment = @library
      @root.save!

      assert_equal @library, @child.lifecycle_environment
      assert_equal @library, @root.lifecycle_environment
    end

    def test_inherited_content_view_with_ancestry
      @root.content_view = @view
      @root.save!

      assert_equal @view, @child.content_view
      assert_equal @view, @root.content_view
    end

    def test_inherited_content_view_with_ancestry_nill
      @child.content_view = @view
      @child.save!

      assert @view == @child.content_view
      assert_nil @root.content_view
    end

    def test_inherited_lifecycle_environment_with_ancestry_nil
      @child.lifecycle_environment = @library
      @child.save!

      assert @library == @child.lifecycle_environment
      assert_nil @root.lifecycle_environment
    end

    def test_content_and_puppet_match?
      @root.content_view = @view
      @root.lifecycle_environment = @library
      @root.environment = @view.version(@library).puppet_env(@library).puppet_environment

      assert @root.content_and_puppet_match?

      @root.lifecycle_environment = @dev
      refute @root.content_and_puppet_match?
    end
  end
end
