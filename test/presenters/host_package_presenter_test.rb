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
    end

    test "with nil upgradable_version" do
      presenter = HostPackagePresenter.new(installed_package, nil, @rpm.id)

      assert_nil presenter.upgradable_versions
      assert_equal presenter.name, installed_package.name
      assert_equal presenter.rpm_id, @rpm.id
    end

    test "with_latest" do
      host = katello_content_facets(:content_facet_one).host
      host.content_facet.bound_repositories << @repo
      update = Katello::Rpm.create(name: 'one', pulp_id: 'one-new-uuid', version: '1.2', nvra: new_version, release: '5', arch: 'x86_64')
      ::Katello::Rpm.stubs(:installable_for_hosts).returns(Katello::Rpm.where(id: update.id))
      presenter = HostPackagePresenter.with_latest([installed_package], host).first

      assert_equal presenter.upgradable_versions, [new_version]
      assert_equal presenter.name, installed_package.name
      assert_equal presenter.rpm_id, @rpm.id
    end

    test "with arch" do
      host = katello_content_facets(:content_facet_one).host
      host.content_facet.bound_repositories << @repo
      update = Katello::Rpm.create(name: 'one', pulp_id: 'one-new-uuid', version: '1.2', nvra: 'one-1.2-5.el7.noarch', release: '5', arch: 'noarch')
      ::Katello::Rpm.stubs(:installable_for_hosts).returns(Katello::Rpm.where(id: update.id))
      presenter = HostPackagePresenter.with_latest([installed_package], host).first

      assert_nil presenter.upgradable_versions
      assert_equal presenter.name, installed_package.name
      assert_equal presenter.rpm_id, @rpm.id
    end
  end
end
