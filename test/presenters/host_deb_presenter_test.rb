require 'katello_test_helper'

module Katello
  class HostDebPresenterTest < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:debian_10_amd64_dev)
      @deb = katello_debs(:one_new)
    end

    let(:installed_deb) { Katello::InstalledDeb.create(name: 'uno', version: @deb.version, architecture: @deb.architecture) }
    let(:new_version) { '1.2' }

    test "deb with set upgradable_version" do
      presenter = HostDebPresenter.new(installed_deb, [new_version], @deb.id)

      assert_equal presenter.upgradable_versions, [new_version]
      assert_equal presenter.name, installed_deb.name
      assert_equal presenter.deb_id, @deb.id
    end

    test "with nil upgradable_version" do
      presenter = HostDebPresenter.new(installed_deb, nil, @deb.id)

      assert_nil presenter.upgradable_versions
      assert_equal presenter.name, installed_deb.name
      assert_equal presenter.deb_id, @deb.id
    end

    test "with_latest" do
      host = katello_content_facets(:content_facet_one).host
      host.content_facet.bound_repositories << @repo
      update = Katello::Deb.create(name: 'uno', pulp_id: 'uno-new-uuid', version: '1.2', architecture: 'amd64')
      ::Katello::Deb.stubs(:installable_for_hosts).returns(Katello::Deb.where(id: update.id))
      presenter = HostDebPresenter.with_latest([installed_deb], host).first

      assert_equal presenter.upgradable_versions, [new_version]
      assert_equal presenter.name, installed_deb.name
      assert_equal presenter.deb_id, @deb.id
    end

    test "with arch" do
      host = katello_content_facets(:content_facet_one).host
      host.content_facet.bound_repositories << @repo
      update = Katello::Deb.create(name: 'one', pulp_id: 'one-new-uuid', version: '1.2', architecture: 'noarch')
      ::Katello::Deb.stubs(:installable_for_hosts).returns(Katello::Deb.where(id: update.id))
      presenter = HostDebPresenter.with_latest([installed_deb], host).first

      assert_nil presenter.upgradable_versions
      assert_equal presenter.name, installed_deb.name
      assert_equal presenter.deb_id, @deb.id
    end
  end
end
