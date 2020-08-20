require 'katello_test_helper'

module Katello
  class ErrataStatusTest < ActiveSupport::TestCase
    let(:security_errata) { katello_errata(:security) }
    let(:bugfix_errata) { katello_errata(:bugfix) }
    let(:repo) { katello_repositories(:rhel_6_x86_64) }
    let(:installed_package) { Katello::InstalledPackage.create(name: 'test-package', nvrea: 'test-package-1.0.x86_64', nvra: 'test-package-1.0.x86_64') }

    let(:host) do
      FactoryBot.create(:host, :with_content, :content_view => katello_content_views(:library_dev_view),
                         :lifecycle_environment => katello_environments(:library))
    end

    let(:status) { host.get_status(Katello::ErrataStatus) }

    def setup
      ForemanTasks.stubs(:async_task) #skip updates errata_status_installable is modified
      Setting['errata_status_installable'] = false
    end

    def test_get_status
      assert host.get_status(Katello::ErrataStatus)
    end

    def test_to_status_security
      host.content_facet.applicable_errata << security_errata
      assert_equal Katello::ErrataStatus::NEEDED_SECURITY_ERRATA, status.to_status
    end

    def test_to_status_non_security
      host.content_facet.applicable_errata << bugfix_errata

      assert_equal Katello::ErrataStatus::NEEDED_ERRATA, status.to_status

      status.refresh!
      assert_equal "Non-security errata applicable", status.to_label
    end

    def test_to_status_no_repos
      host.installed_packages << installed_package

      status.refresh!

      assert_empty host.content_facet.bound_repositories
      assert_equal Katello::ErrataStatus::UNKNOWN, status.to_status
      assert_match(/enabled repositories/, status.to_label)
    end

    def test_to_status_no_packages
      host.content_facet.bound_repositories << repo

      status.refresh!

      assert_empty host.installed_packages
      assert_equal Katello::ErrataStatus::UNKNOWN, status.to_status
      assert_match(/installed packages/, status.to_label)
    end

    def test_to_status_repos_no_errata
      host.content_facet.bound_repositories << repo
      host.installed_packages << installed_package

      assert_equal Katello::ErrataStatus::UP_TO_DATE, status.to_status
      assert_equal "All errata applied", status.to_label
    end

    def test_no_content_facet
      host.content_facet.destroy
      host.reload

      refute status.relevant?
    end

    def test_to_global
      status.status = Katello::ErrataStatus::UNKNOWN
      assert_equal HostStatus::Global::WARN, status.to_global
    end

    def test_installable
      Setting['errata_status_installable'] = true
      host.content_facet.bound_repositories << repo
      host.content_facet.applicable_errata << bugfix_errata
      host.installed_packages << installed_package
      host.content_facet.expects(:installable_errata).returns(Erratum.none)

      assert_equal Katello::ErrataStatus::UP_TO_DATE, status.to_status
      assert_equal "All errata applied", status.to_label
    end
  end
end
