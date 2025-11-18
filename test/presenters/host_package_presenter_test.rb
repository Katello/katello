require 'katello_test_helper'

module Katello
  class HostPackagePresenterTest < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:fedora_17_x86_64)
      @rpm = katello_rpms(:one)
    end

    let(:installed_package) { Katello::InstalledPackage.create(name: @rpm.name, nvra: @rpm.nvra, version: @rpm.version, release: @rpm.release, nvrea: @rpm.nvrea, arch: @rpm.arch) }
    let(:new_version) { 'one-1.2-5.el7.x86_64' }

    test "with set upgradable_version" do
      presenter = HostPackagePresenter.new(installed_package, [new_version], @rpm.id)

      assert_equal presenter.upgradable_versions, [new_version]
      assert_equal presenter.name, installed_package.name
      assert_equal presenter.rpm_id, @rpm.id
      assert_nil presenter.persistence
    end

    test "with nil upgradable_version" do
      presenter = HostPackagePresenter.new(installed_package, nil, @rpm.id)

      assert_nil presenter.upgradable_versions
      assert_equal presenter.name, installed_package.name
      assert_equal presenter.rpm_id, @rpm.id
      assert_nil presenter.persistence
    end

    test "with persistence value" do
      presenter = HostPackagePresenter.new(installed_package, nil, @rpm.id, 'persistent')

      assert_equal presenter.persistence, 'persistent'
      assert_equal presenter.name, installed_package.name
    end

    test "package_map with include_upgradable" do
      host = katello_content_facets(:content_facet_one).host
      host.content_facet.bound_repositories << @repo
      update = Katello::Rpm.create(name: 'one', pulp_id: 'one-new-uuid', version: '1.2', nvra: new_version, release: '5', arch: 'x86_64')
      ::Katello::Rpm.stubs(:installable_for_hosts).returns(Katello::Rpm.where(id: update.id))
      presenter = HostPackagePresenter.package_map([installed_package], host, true, false).first

      assert_equal presenter.upgradable_versions, [new_version]
      assert_equal presenter.name, installed_package.name
      assert_equal presenter.rpm_id, @rpm.id
      assert_nil presenter.persistence
    end

    test "package_map with arch mismatch" do
      host = katello_content_facets(:content_facet_one).host
      host.content_facet.bound_repositories << @repo
      update = Katello::Rpm.create(name: 'one', pulp_id: 'one-new-uuid', version: '1.2', nvra: 'one-1.2-5.el7.noarch', release: '5', arch: 'noarch')
      ::Katello::Rpm.stubs(:installable_for_hosts).returns(Katello::Rpm.where(id: update.id))
      presenter = HostPackagePresenter.package_map([installed_package], host, true, false).first

      assert_nil presenter.upgradable_versions
      assert_equal presenter.name, installed_package.name
      assert_equal presenter.rpm_id, @rpm.id
    end

    test "package_map with include_persistence" do
      host = katello_content_facets(:content_facet_one).host
      Katello::HostInstalledPackage.create!(host: host, installed_package: installed_package, persistence: 'transient')
      presenter = HostPackagePresenter.package_map([installed_package], host, false, true).first

      assert_equal presenter.persistence, 'transient'
      assert_equal presenter.name, installed_package.name
      assert_nil presenter.upgradable_versions
    end

    test "package_map with both include_upgradable and include_persistence" do
      host = katello_content_facets(:content_facet_one).host
      host.content_facet.bound_repositories << @repo
      update = Katello::Rpm.create(name: 'one', pulp_id: 'one-new-uuid', version: '1.2', nvra: new_version, release: '5', arch: 'x86_64')
      ::Katello::Rpm.stubs(:installable_for_hosts).returns(Katello::Rpm.where(id: update.id))
      Katello::HostInstalledPackage.create!(host: host, installed_package: installed_package, persistence: 'persistent')
      presenter = HostPackagePresenter.package_map([installed_package], host, true, true).first

      assert_equal presenter.upgradable_versions, [new_version]
      assert_equal presenter.persistence, 'persistent'
      assert_equal presenter.name, installed_package.name
      assert_equal presenter.rpm_id, @rpm.id
    end

    test "package_map without include flags" do
      host = katello_content_facets(:content_facet_one).host
      presenter = HostPackagePresenter.package_map([installed_package], host, false, false).first

      assert_nil presenter.upgradable_versions
      assert_nil presenter.persistence
      assert_equal presenter.name, installed_package.name
    end
  end
end
