# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostPackagesControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    tests ::Katello::Api::V2::HostPackagesController

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

      @host = hosts(:one)
      @system = katello_systems(:simple_server)

      @host.content_host = @system

      setup_foreman_routes
      permissions
    end

    def test_install_package
      assert_async_task ::Actions::Katello::System::Package::Install do |system, packages|
        system.id == @system.id && packages == %w(foo)
      end

      put :install, :host_id => @host.id, :packages => %w(foo)

      assert_response :success
    end

    def test_install_bad_package
      put :install, :host_id => @host.id, :packages => ["foo343434*"]

      assert_response 400
    end

    def test_install_group
      assert_async_task ::Actions::Katello::System::PackageGroup::Install do |system, groups|
        system.id == @system.id && groups == %w(blah)
      end

      put :install, :host_id => @host.id, :groups => %w(blah)

      assert_response :success
    end

    def test_upgrade
      assert_async_task ::Actions::Katello::System::Package::Update do |system, packages|
        system.id == @system.id && packages == %w(foo bar)
      end

      put :upgrade, :host_id => @host.id, :packages => %w(foo bar)

      assert_response :success
    end

    def test_upgrade_group_fail
      put :upgrade, :host_id => @host.id, :groups => %w(foo bar)

      assert_response 400
    end

    def test_upgrade_all
      assert_async_task ::Actions::Katello::System::Package::Update do |system, packages|
        system.id == @system.id && packages == []
      end

      put :upgrade_all, :host_id => @host.id

      assert_response :success
    end

    def test_remove
      assert_async_task ::Actions::Katello::System::Package::Remove do |system, packages|
        system.id == @system.id && packages == %w(foo)
      end

      put :remove, :host_id => @host.id, :packages => %w(foo)

      assert_response :success
    end

    def test_remove_group
      assert_async_task ::Actions::Katello::System::PackageGroup::Remove do |system, groups|
        system.id == @system.id && groups == %w(blah)
      end

      put :remove, :host_id => @host.id, :groups => %w(blah)

      assert_response :success
    end

    def test_permissions
      #all actions have the same perms
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:install, good_perms, bad_perms) do
        put :install, :host_id => @host.id, :packages => ["foo*"]
      end

      assert_protected_action(:upgrade, good_perms, bad_perms) do
        put :upgrade, :host_id => @host.id, :packages => ["foo*"]
      end

      assert_protected_action(:upgrade_all, good_perms, bad_perms) do
        put :upgrade_all, :host_id => @host.id, :packages => ["foo*"]
      end

      assert_protected_action(:remove, good_perms, bad_perms) do
        put :remove, :host_id => @host.id, :packages => ["foo*"]
      end
    end
  end
end
