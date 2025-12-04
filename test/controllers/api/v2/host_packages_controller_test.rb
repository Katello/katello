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
      HostPackagePresenter.expects(:package_map).with(anything, @host, true, true).returns([])

      get :index, params: { :host_id => @host.id, :include_latest_upgradable => true }

      assert_response :success
    end

    def test_index_includes_persistence
      installed_pkg = @host.installed_packages.first
      Katello::HostInstalledPackage.where(host: @host, installed_package: installed_pkg).update_all(persistence: 'transient')

      get :index, params: { :host_id => @host.id }

      assert_response :success
      response_data = JSON.parse(response.body)
      results = response_data['results']

      package = results.find { |p| p['id'] == installed_pkg.id }
      assert package, "Package #{installed_pkg.id} not found in results"
      assert_equal 'transient', package['persistence']
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

    def test_containerfile_install_command
      installed_pkg = @host.installed_packages.first
      Katello::HostInstalledPackage.where(host: @host, installed_package: installed_pkg).update_all(persistence: 'transient')

      get :containerfile_install_command, params: { :host_id => @host.id }

      assert_response :success
      response_data = JSON.parse(response.body)
      assert response_data.key?('command')
      assert response_data.key?('message')
      assert_nil response_data['message']
      assert_match(/^RUN dnf install -y/, response_data['command'])
      assert_match(/#{installed_pkg.nvrea}/, response_data['command'])
    end

    def test_containerfile_install_command_with_search
      installed_pkg = @host.installed_packages.first
      Katello::HostInstalledPackage.where(host: @host, installed_package: installed_pkg).update_all(persistence: 'transient')

      get :containerfile_install_command, params: { :host_id => @host.id, :search => "name=#{installed_pkg.name}" }

      assert_response :success
      response_data = JSON.parse(response.body)
      assert_match(/#{installed_pkg.nvrea}/, response_data['command'])
      assert_nil response_data['message']
    end

    def test_containerfile_install_command_only_transient
      transient_pkg = @host.installed_packages.first
      persistent_pkg = @host.installed_packages.second
      Katello::HostInstalledPackage.where(host: @host, installed_package: transient_pkg).update_all(persistence: 'transient')
      Katello::HostInstalledPackage.where(host: @host, installed_package: persistent_pkg).update_all(persistence: 'persistent')

      get :containerfile_install_command, params: { :host_id => @host.id }

      assert_response :success
      response_data = JSON.parse(response.body)
      assert_match(/#{transient_pkg.nvrea}/, response_data['command'])
      refute_match(/#{persistent_pkg.nvrea}/, response_data['command'])
      assert_nil response_data['message']
    end

    def test_containerfile_install_command_no_transient_packages
      @host.installed_packages.each do |pkg|
        Katello::HostInstalledPackage.where(host: @host, installed_package: pkg).update_all(persistence: 'persistent')
      end

      get :containerfile_install_command, params: { :host_id => @host.id }

      assert_response :not_found
      response_data = JSON.parse(response.body)
      assert_nil response_data['command']
      assert_equal "No transient packages found", response_data['message']
    end

    def test_containerfile_install_command_search_no_match
      installed_pkg = @host.installed_packages.first
      Katello::HostInstalledPackage.where(host: @host, installed_package: installed_pkg).update_all(persistence: 'transient')

      get :containerfile_install_command, params: { :host_id => @host.id, :search => "name=nonexistent-package" }

      assert_response :not_found
      response_data = JSON.parse(response.body)
      assert_nil response_data['command']
      assert_equal "No transient packages found", response_data['message']
    end

    def test_containerfile_install_command_permissions
      ::Host.any_instance.stubs(:check_host_registration).returns(true)

      good_perms = [@view_permission]
      bad_perms = [@update_permission, @create_permission, @destroy_permission]

      assert_protected_action(:containerfile_install_command, good_perms, bad_perms) do
        user = User.current
        as_admin do
          user.update_attribute(:organizations, [taxonomies(:organization1)])
          @host.update_attribute(:organization, taxonomies(:organization1))
          user.update_attribute(:locations, [taxonomies(:location1)])
          @host.update_attribute(:location, taxonomies(:location1))
        end

        get :containerfile_install_command, params: { :host_id => @host.id }
      end
    end

    def test_containerfile_install_command_unauthorized_org
      ::Host.any_instance.stubs(:check_host_registration).returns(true)

      installed_pkg = @host.installed_packages.first
      Katello::HostInstalledPackage.where(host: @host, installed_package: installed_pkg).update_all(persistence: 'transient')

      user = User.find(users(:restricted).id)
      as_admin do
        user.update_attribute(:organizations, [taxonomies(:organization2)])
        user.update_attribute(:locations, [taxonomies(:location1)])
        @host.update_attribute(:organization, taxonomies(:organization1))
        setup_user_with_permissions(:view_hosts, user)
      end

      login_user(user)
      get :containerfile_install_command, params: { :host_id => @host.id }

      assert_response :not_found
    end

    def test_containerfile_install_command_multiple_packages
      pkg1 = @host.installed_packages.first
      pkg2 = @host.installed_packages.second
      Katello::HostInstalledPackage.where(host: @host, installed_package: pkg1).update_all(persistence: 'transient')
      Katello::HostInstalledPackage.where(host: @host, installed_package: pkg2).update_all(persistence: 'transient')

      get :containerfile_install_command, params: { :host_id => @host.id }

      assert_response :success
      response_data = JSON.parse(response.body)
      command = response_data['command']

      assert_match(/^RUN dnf install -y/, command)
      assert_match(/#{pkg1.nvrea}/, command)
      assert_match(/#{pkg2.nvrea}/, command)
      assert(command.include?("#{pkg1.nvrea} #{pkg2.nvrea}") || command.include?("#{pkg2.nvrea} #{pkg1.nvrea}"), "Packages should be space-separated")
    end

    def test_containerfile_install_command_excludes_nil_persistence
      transient_pkg = @host.installed_packages.first
      nil_persistence_pkg = @host.installed_packages.second

      Katello::HostInstalledPackage.where(host: @host, installed_package: transient_pkg).update_all(persistence: 'transient')
      Katello::HostInstalledPackage.where(host: @host, installed_package: nil_persistence_pkg).update_all(persistence: nil)

      get :containerfile_install_command, params: { :host_id => @host.id }

      assert_response :success
      response_data = JSON.parse(response.body)
      command = response_data['command']

      assert_match(/#{transient_pkg.nvrea}/, command)
      refute_match(/#{nil_persistence_pkg.nvrea}/, command)
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
