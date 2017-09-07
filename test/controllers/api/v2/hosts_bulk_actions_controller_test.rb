# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostsBulkActionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def permissions
      @view_permission = :view_hosts
      @update_permission = :edit_hosts
      @destroy_permission = :destroy_hosts
    end

    def models
      @view = katello_content_views(:library_view)

      @view_2 = katello_content_views(:acme_default)
      @library = katello_environments(:library)

      @host1 = FactoryGirl.create(:host, :with_content, :organization => @view.organization, :content_view => @view, :lifecycle_environment => @library)
      @host2 = FactoryGirl.create(:host, :with_content, :organization => @view.organization, :content_view => @view, :lifecycle_environment => @library)
      @host_ids = [@host1.id, @host2.id]

      @org = @view.organization
      @host_collection1 = katello_host_collections(:simple_host_collection)
      @host_collection1.hosts << @host1
      @host_collection2 = katello_host_collections(:another_simple_host_collection)
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      setup_foreman_routes
      permissions
      models
    end

    def test_add_host_collection
      assert_equal 1, @host1.host_collections.count # system initially has simple_host_collection
      put :bulk_add_host_collections, :included => {:ids => @host_ids},
                                      :organization_id => @org.id,
                                      :host_collection_ids => [@host_collection1.id, @host_collection2.id]

      assert_response :success
      assert_equal 2, @host1.host_collections.count
    end

    def test_remove_host_collection
      assert_equal 1, @host1.host_collections.count # system initially has simple_host_collection
      put :bulk_remove_host_collections, :included => {:ids => @host_ids},
                                         :organization_id => @org.id,
                                         :host_collection_ids => [@host_collection1.id, @host_collection2.id]

      assert_response :success
      assert_equal 0, @host1.host_collections.count
    end

    def test_install_package
      BulkActions.any_instance.expects(:install_packages).once.returns({})

      put :install_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :content_type => 'package', :content => ['foo']

      assert_response :success
    end

    def test_update_package
      BulkActions.any_instance.expects(:update_packages).once.returns({})

      put :update_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :content_type => 'package', :content => ['foo']

      assert_response :success
    end

    def test_remove_package
      BulkActions.any_instance.expects(:uninstall_packages).once.returns({})

      put :remove_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :content_type => 'package', :content => ['foo']

      assert_response :success
    end

    def test_install_package_group
      BulkActions.any_instance.expects(:install_package_groups).once.returns({})

      put :install_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :content_type => 'package_group', :content => ['foo group']

      assert_response :success
    end

    def test_update_package_group
      BulkActions.any_instance.expects(:update_package_groups).once.returns({})

      put :update_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :content_type => 'package_group', :content => ['foo group']

      assert_response :success
    end

    def test_remove_package_group
      BulkActions.any_instance.expects(:uninstall_package_groups).once.returns({})

      put :remove_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :content_type => 'package_group', :content => ['foo group']

      assert_response :success
    end

    def test_install_errata
      errata = katello_errata("bugfix")
      @host1.content_facet.applicable_errata << errata
      @controller.expects(:async_task).with(::Actions::BulkAction, ::Actions::Katello::Host::Erratum::ApplicableErrataInstall,
                                            [@host1], [errata.uuid]).returns({})

      put :install_content, :included => {:ids => [@host1.id]}, :organization_id => @org.id,
          :content_type => 'errata', :content => [errata.errata_id]

      assert_response :success
    end

    def test_destroy_hosts
      assert_async_task(::Actions::BulkAction) do |action_class, hosts|
        assert_equal action_class, ::Actions::Katello::Host::Destroy
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end

      put :destroy_hosts, :included => {:ids => @host_ids}, :organization_id => @org.id
      assert_response :success
    end

    def test_content_view_environment
      assert_async_task(::Actions::BulkAction) do |action_class, hosts, view_id, library_id|
        assert_equal action_class, ::Actions::Katello::Host::UpdateContentView
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal @view_2.id, view_id
        assert_equal @library.id, library_id
      end

      put :environment_content_view, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :environment_id => @library.id, :content_view_id => @view_2.id

      assert_response :success
    end

    def test_release_version
      release_version = "7.2"
      assert_async_task(::Actions::BulkAction) do |action_class, hosts, release_version_param|
        assert_equal action_class, ::Actions::Katello::Host::UpdateReleaseVersion
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal release_version, release_version_param
      end

      put :release_version, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :release_version => release_version

      assert_response :success
    end

    def test_release_version_permission
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      assert_protected_action(:release_version, good_perms, bad_perms) do
        put :release_version, :included => {:ids => @host_ids}, :organization_id => @org.id,
          :release_version => "7.2"
      end
    end

    def allow_restricted_user_to_see_host
      users(:restricted).update_attribute(:organizations, [@org])
      users(:restricted).update_attribute(:locations, [@host1.location, @host2.location].uniq)
    end

    def test_permissions
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      assert_protected_action(:bulk_add_host_collections, good_perms, bad_perms) do
        put :bulk_add_host_collections,  :included => {:ids => @host_ids},
                                         :organization_id => @org.id,
                                         :host_collection_ids => [@host_collection1.id, @host_collection2.id]
      end

      assert_protected_action(:bulk_remove_host_collections, good_perms, bad_perms) do
        put :bulk_remove_host_collections,  :included => {:ids => @host_ids},
                                            :organization_id => @org.id,
                                            :host_collection_ids => [@host_collection1.id, @host_collection2.id]
      end

      assert_protected_action(:install_content, good_perms, bad_perms) do
        put :install_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
            :content_type => 'package', :content => ['foo']
      end

      assert_protected_action(:update_content, good_perms, bad_perms) do
        put :update_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
            :content_type => 'package', :content => ['foo']
      end

      assert_protected_action(:remove_content, good_perms, bad_perms) do
        put :remove_content, :included => {:ids => @host_ids}, :organization_id => @org.id,
            :content_type => 'package', :content => ['foo']
      end

      good_perms = [@destroy_permission]
      bad_perms = [@view_permission, @update_permission]

      assert_protected_action(:destroy_hosts, good_perms, bad_perms) do
        put :destroy_hosts, :included => {:ids => @host_ids}, :organization_id => @org.id
      end
    end

    def test_environment_content_view_permission
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      assert_protected_action(:environment_content_view, good_perms, bad_perms) do
        put :environment_content_view, :included => {:ids => @host_ids}, :organization_id => @org.id,
            :environment_id => @library.id, :content_view_id => @view.id
      end
    end

    def test_available_incremental_updates
      ContentViewVersion.any_instance.stubs(:package_count).returns(0)
      ContentViewVersion.any_instance.stubs(:errata_count).returns(0)
      ContentViewVersion.any_instance.stubs(:puppet_module_count).returns(0)

      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)

      @host1.content_facet.applicable_errata = @view_repo.errata

      @cv = katello_content_views(:library_dev_view)
      @env = katello_environments(:dev)

      unavailable = @host1.content_facet.applicable_errata -
          @host1.content_facet.installable_errata(@env, @cv)
      @missing_erratum = unavailable.first

      assert @missing_erratum
      post :available_incremental_updates, :included => {:ids => [@host1.id]}, :organization_id => @org.id, :errata_ids => [@missing_erratum.errata_id]
      assert_response :success
    end

    def test_subscription_permissions
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      pool = katello_pools(:pool_one)

      assert_protected_action(:content_overrides, good_perms, bad_perms) do
        put :content_overrides, :included => {:ids => @host_ids},
            :content_overrides => [{:content_label => 'some-content', :value => 1}]
      end

      assert_protected_action(:add_subscriptions, good_perms, bad_perms) do
        put :add_subscriptions, :included => {:ids => @host_ids},
            :subscriptions => [{:id => pool.id, :quantity => 1}]
      end

      assert_protected_action(:remove_subscriptions, good_perms, bad_perms) do
        put :remove_subscriptions, :included => {:ids => @host_ids},
            :subscriptions => [{:id => pool.id, :quantity => 1}]
      end

      assert_protected_action(:auto_attach, good_perms, bad_perms) do
        put :auto_attach, :included => {:ids => @host_ids}
      end
    end

    def test_add_subscriptions
      pool = katello_pools(:pool_one)

      assert_async_task(::Actions::BulkAction) do |action_class, hosts, pools_with_quantities|
        assert_equal action_class, ::Actions::Katello::Host::AttachSubscriptions
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal pool, pools_with_quantities[0].pool
        assert_equal ["1"], pools_with_quantities[0].quantities
      end
      put :add_subscriptions, :included => {:ids => @host_ids}, :subscriptions => [{:id => pool.id, :quantity => 1}]
      assert_response :success
    end

    def test_remove_subscriptions
      pool = katello_pools(:pool_one)

      assert_async_task(::Actions::BulkAction) do |action_class, hosts, pools_with_quantities|
        assert_equal action_class, ::Actions::Katello::Host::RemoveSubscriptions
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal pool, pools_with_quantities[0].pool
        assert_equal ["1"], pools_with_quantities[0].quantities
      end
      put :remove_subscriptions, :included => {:ids => @host_ids}, :subscriptions => [{:id => pool.id, :quantity => 1}]
      assert_response :success
    end

    def test_auto_attach
      assert_async_task(::Actions::BulkAction) do |action_class, hosts|
        assert_equal action_class, ::Actions::Katello::Host::AutoAttachSubscriptions
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end
      put :auto_attach, :included => {:ids => @host_ids}
      assert_response :success
    end

    def test_content_overrides
      expected_content_overrides = [{:content_label => 'some-content', :value => 1},
                                    {:content_label => 'some-content2', :value => "default"}]
      expected_content_labels = expected_content_overrides.map { |override| override[:content_label] }
      expected_values = ["1", nil]

      assert_async_task(::Actions::BulkAction) do |action_class, hosts, content_overrides|
        assert_equal action_class, ::Actions::Katello::Host::UpdateContentOverrides
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal expected_content_overrides.size, content_overrides.size
        assert_equal expected_content_labels, content_overrides.map(&:content_label)
        assert_equal expected_values, content_overrides.map(&:value)
      end
      put :content_overrides, :included => {:ids => @host_ids}, :content_overrides => expected_content_overrides
      assert_response :success
    end
  end
end
