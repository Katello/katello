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
      set_request_headers
      setup_hosts
      setup_installed_packages
      setup_foreman_routes
      permissions
    end

    def test_index
      get :index, params: { :host_id => @host.id }

      assert_response :success
    end

    def test_installed_packages
      response = get :installed_packages

      assert_response :success
      assert_template layout: "katello/api/v2/layouts/collection"
      assert_template "katello/api/v2/host_packages/installed_packages"

      response_data = JSON.parse(response.body)
      results = response_data['results'] || []

      assert_includes results.map { |rpm| rpm['name'] }, @rpm.name
      assert_equal InstalledPackage.first.name, results[0]['name']
      assert_equal InstalledPackage.second.name, results[0]['name']
      assert_operator results.size, :<, InstalledPackage.all.count
    end

    def test_include_latest_upgradable
      HostPackagePresenter.expects(:with_latest).with(anything, @host)

      get :index, params: { :host_id => @host.id, :include_latest_upgradable => true }

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

    private

    def set_request_headers
      @request.env['HTTP_ACCEPT'] = 'application/json'
    end

    def setup_hosts
      @host = hosts(:one)
      @content_facet = katello_content_facets(:content_facet_one)
      @host.content_facet = @content_facet
    end

    def setup_installed_packages
      @rpm = katello_rpms(:one)
      @rpm2 = katello_rpms(:two)
      @host.installed_packages << Katello::InstalledPackage.create(name: @rpm.name, nvra: @rpm.nvra, version: @rpm.version, release: @rpm.release, nvrea: @rpm.nvrea, arch: @rpm.arch)
      @host.installed_packages << Katello::InstalledPackage.create(name: @rpm.name, nvra: @rpm2.nvra, version: @rpm2.version, release: @rpm2.release, nvrea: @rpm2.nvrea, arch: @rpm2.arch)
      @host.reload
    end
  end
end
