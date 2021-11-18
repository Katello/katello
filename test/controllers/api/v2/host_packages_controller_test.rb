# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostPackagesControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    tests ::Katello::Api::V2::HostPackagesController

    def permissions
      @view_permission = :view_hosts
      @create_permission = :create_hosts
      @update_permission = :edit_hosts
      @destroy_permission = :destroy_hosts
    end

    def setup
      setup_controller_defaults_api
      login_user(users(:admin))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      @host = hosts(:one)
      @content_facet = katello_content_facets(:content_facet_one)
      @host.content_facet = @content_facet

      setup_foreman_routes
      permissions
    end

    def test_index
      get :index, params: { :host_id => @host.id }

      assert_response :success
    end

    def test_include_latest_upgradable
      HostPackagePresenter.expects(:with_latest).with(anything, @host)

      get :index, params: { :host_id => @host.id, :include_latest_upgradable => true }

      assert_response :success
    end

    def test_install_package
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task ::Actions::Katello::Host::Package::Install do |host, options|
        host.id == @host.id && options[:content] == %w(foo)
      end

      put :install, params: { :host_id => @host.id, :packages => %w(foo) }

      assert_response :success
    end

    def test_install_bad_package
      put :install, params: { :host_id => @host.id, :packages => ["foo343434*"] }

      assert_response 400
    end

    def test_install_group
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task ::Actions::Katello::Host::PackageGroup::Install do |host, options|
        host.id == @host.id && options[:content] == %w(blah)
      end

      put :install, params: { :host_id => @host.id, :groups => %w(blah) }

      assert_response :success
    end

    def test_upgrade
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task ::Actions::Katello::Host::Package::Update do |host, options|
        host.id == @host.id && options[:content] == %w(foo bar)
      end

      put :upgrade, params: { :host_id => @host.id, :packages => %w(foo bar) }

      assert_response :success
    end

    def test_upgrade_group_fail
      put :upgrade, params: { :host_id => @host.id, :groups => %w(foo bar) }

      assert_response 400
    end

    def test_upgrade_all
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task ::Actions::Katello::Host::Package::Update do |host, options|
        host.id == @host.id && options[:content] == []
      end

      put :upgrade_all, params: { :host_id => @host.id }

      assert_response :success
    end

    def test_remove
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task ::Actions::Katello::Host::Package::Remove do |host, options|
        host.id == @host.id && options[:content] == %w(foo)
      end

      put :remove, params: { :host_id => @host.id, :packages => %w(foo) }

      assert_response :success
    end

    def test_invalid_package_input
      methods = [:remove, :install, :upgrade]

      methods.each do |method|
        put method, params: { host_id: @host.id, packages: [{name: 'foo'}] }
        assert_response 400

        put method, params: { host_id: @host.id, packages: %w(*) }
        assert_response 400
      end
    end

    def test_remove_group
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task ::Actions::Katello::Host::PackageGroup::Remove do |host, options|
        host.id == @host.id && options[:content] == %w(blah)
      end

      put :remove, params: { :host_id => @host.id, :groups => %w(blah) }

      assert_response :success
    end

    def test_view_permissions
      ::Host.any_instance.stubs(:check_host_registration).returns(true)

      good_perms = [@view_permission]
      bad_perms = [@update_permission, @create_permission, @destroy_permission]

      assert_protected_action(:index, good_perms, bad_perms) do
        user = User.current
        as_admin do
          user.update_attribute(:organizations, [taxonomies(:organization1)])
          @host.update_attribute(:organization, taxonomies(:organization1))
          user.update_attribute(:locations, [taxonomies(:location1)])
          @host.update_attribute(:location, taxonomies(:location1))
        end

        get :index, params: { :host_id => @host.id }
      end
    end

    def test_permissions
      ::Host.any_instance.stubs(:check_host_registration).returns(true)
      ::Katello.stubs(:with_katello_agent?).returns(true)

      good_perms = [@update_permission]
      bad_perms = [@view_permission, @create_permission, @destroy_permission]

      # Ensure the user that will run the actions has access to the host taxonomies
      users(:restricted).update_attribute(:organizations, [taxonomies(:organization1)])
      @host.update_attribute(:organization, taxonomies(:organization1))
      users(:restricted).update_attribute(:locations, [taxonomies(:location1)])
      @host.update_attribute(:location, taxonomies(:location1))

      assert_protected_action(:install, good_perms, bad_perms) do
        put :install, params: { :host_id => @host.id, :packages => ["foo*"] }
      end

      assert_protected_action(:upgrade, good_perms, bad_perms) do
        put :upgrade, params: { :host_id => @host.id, :packages => ["foo*"] }
      end

      assert_protected_action(:upgrade_all, good_perms, bad_perms) do
        put :upgrade_all, params: { :host_id => @host.id, :packages => ["foo*"] }
      end

      assert_protected_action(:remove, good_perms, bad_perms) do
        put :remove, params: { :host_id => @host.id, :packages => ["foo*"] }
      end
    end
  end
end
