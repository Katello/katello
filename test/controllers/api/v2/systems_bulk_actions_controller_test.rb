# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::SystemsBulkActionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def permissions
      @view_permission = :view_content_hosts
      @create_permission = :create_content_hosts
      @update_permission = :edit_content_hosts
      @destroy_permission = :destroy_content_hosts
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      @system1 = System.find(katello_systems(:simple_server))
      @system2 = System.find(katello_systems(:simple_server2))
      @systems = [@system1, @system2]
      @system_ids = @systems.map(&:uuid)
      @host1 = hosts(:one)
      @host2 = hosts(:two)

      @system1.foreman_host = @host1
      @system2.foreman_host = @host2

      @org = get_organization
      @view = katello_content_views(:library_view)
      @library = @org.library
      @host_collection1 = katello_host_collections(:simple_host_collection)
      @host_collection2 = katello_host_collections(:another_simple_host_collection)

      permissions

      System.any_instance.stubs(:update_host_collections)
    end

    def test_add_host_collection
      assert_equal 1, @system1.foreman_host.host_collections.count # system initially has simple_host_collection
      put :bulk_add_host_collections, :included => {:ids => @system_ids},
                                      :organization_id => @org.id,
                                      :host_collection_ids => [@host_collection1.id, @host_collection2.id]

      assert_response :success
      assert_equal 2, @system1.foreman_host.host_collections.count
    end

    def test_remove_host_collection
      assert_equal 1, @system1.foreman_host.host_collections.count # system initially has simple_host_collection
      put :bulk_remove_host_collections, :included => {:ids => @system_ids},
                                         :organization_id => @org.id,
                                         :host_collection_ids => [@host_collection1.id, @host_collection2.id]

      assert_response :success
      assert_equal 0, @system1.foreman_host.host_collections.count
    end

    def test_install_package
      BulkActions.any_instance.expects(:install_packages).once.returns(Job.new)

      put :install_content,  :included => {:ids => @system_ids}, :organization_id => @org.id,
          :content_type => 'package', :content => ['foo']

      assert_response :success
    end

    def test_update_package
      BulkActions.any_instance.expects(:update_packages).once.returns(Job.new)

      put :update_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
          :content_type => 'package', :content => ['foo']

      assert_response :success
    end

    def test_remove_package
      BulkActions.any_instance.expects(:uninstall_packages).once.returns(Job.new)

      put :remove_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
          :content_type => 'package', :content => ['foo']

      assert_response :success
    end

    def test_install_package_group
      BulkActions.any_instance.expects(:install_package_groups).once.returns(Job.new)

      put :install_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
          :content_type => 'package_group', :content => ['foo group']

      assert_response :success
    end

    def test_update_package_group
      BulkActions.any_instance.expects(:update_package_groups).once.returns(Job.new)

      put :update_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
          :content_type => 'package_group', :content => ['foo group']

      assert_response :success
    end

    def test_remove_package_group
      BulkActions.any_instance.expects(:uninstall_package_groups).once.returns(Job.new)

      put :remove_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
          :content_type => 'package_group', :content => ['foo group']

      assert_response :success
    end

    def test_install_errata
      query = System.editable.where(:uuid => @system_ids).
          where(:environment_id => @org.kt_environments).collect { |system| system.foreman_host }
      errata = katello_errata("bugfix")

      @controller.expects(:async_task).with(::Actions::BulkAction, ::Actions::Katello::Host::Erratum::ApplicableErrataInstall,
                                            query, [errata.uuid]).returns({})

      put :install_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
          :content_type => 'errata', :content => [errata.errata_id]

      assert_response :success
    end

    def test_destroy_systems
      System.stubs(:where).returns(System.where(:id => [@system1.id, @system2.id]))
      assert_sync_task(::Actions::Katello::System::Destroy, @system1)
      assert_sync_task(::Actions::Katello::System::Destroy, @system2)

      put :destroy_systems, :included => {:ids => @system_ids}, :organization_id => @org.id
      assert_response :success
    end

    def test_content_view_environment
      put :environment_content_view, :included => {:ids => @system_ids}, :organization_id => @org.id,
          :environment_id => @library.id, :content_view_id => @view.id

      assert_response :success
      system = System.find_by_id(@system1)
      assert_equal @view.id, system.content_view_id
      assert_equal @library.id, system.environment_id
    end

    def test_permissions
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission, @create_permission]

      assert_protected_action(:bulk_add_host_collections, good_perms, bad_perms) do
        put :bulk_add_host_collections,  :included => {:ids => @system_ids},
                                         :organization_id => @org.id,
                                         :host_collection_ids => [@host_collection1.id, @host_collection2.id]
      end

      assert_protected_action(:bulk_remove_host_collections, good_perms, bad_perms) do
        put :bulk_remove_host_collections,  :included => {:ids => @system_ids},
                                            :organization_id => @org.id,
                                            :host_collection_ids => [@host_collection1.id, @host_collection2.id]
      end

      assert_protected_action(:install_content, good_perms, bad_perms) do
        put :install_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
            :content_type => 'package', :content => ['foo']
      end

      assert_protected_action(:update_content, good_perms, bad_perms) do
        put :update_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
            :content_type => 'package', :content => ['foo']
      end

      assert_protected_action(:remove_content, good_perms, bad_perms) do
        put :remove_content, :included => {:ids => @system_ids}, :organization_id => @org.id,
            :content_type => 'package', :content => ['foo']
      end

      good_perms = [@destroy_permission]
      bad_perms = [@view_permission, @update_permission, @create_permission]

      assert_protected_action(:destroy_systems, good_perms, bad_perms) do
        put :destroy_systems, :included => {:ids => @system_ids}, :organization_id => @org.id
      end
    end

    def test_environment_content_view_permission
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission, @create_permission]

      assert_protected_action(:environment_content_view, good_perms, bad_perms) do
        put :environment_content_view, :included => {:ids => @system_ids}, :organization_id => @org.id,
            :environment_id => @library.id, :content_view_id => @view.id
      end
    end

    def test_available_incremental_updates
      ContentViewVersion.any_instance.stubs(:package_count).returns(0)
      ContentViewVersion.any_instance.stubs(:errata_count).returns(0)
      ContentViewVersion.any_instance.stubs(:puppet_module_count).returns(0)

      @errata_system = System.find(katello_systems(:errata_server))
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))

      @errata_system.foreman_host = hosts(:one)
      @errata_system.foreman_host.content_facet = katello_content_facets(:one)
      @errata_system.foreman_host.content_facet.applicable_errata = @view_repo.errata
      @errata_system.save!

      @cv = katello_content_views(:library_dev_view)
      @env = katello_environments(:dev)

      unavailable = @errata_system.foreman_host.content_facet.applicable_errata -
          @errata_system.foreman_host.content_facet.installable_errata(@env, @cv)
      @missing_erratum = unavailable.first

      assert @missing_erratum
      post :available_incremental_updates, :included => {:ids => [@errata_system.uuid]}, :organization_id => @org.id, :errata_ids => [@missing_erratum.uuid]
      assert_response :success
    end
  end
end
