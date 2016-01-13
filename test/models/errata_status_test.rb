require 'katello_test_helper'

module Katello
  class ErrataStatusTest < ActiveSupport::TestCase
    let(:security_errata) { katello_errata(:security) }
    let(:bugfix_errata) { katello_errata(:bugfix) }
    let(:repo) { katello_repositories(:rhel_6_x86_64) }

    let(:host) do
      FactoryGirl.create(:host, :with_content, :content_view => katello_content_views(:library_dev_view),
                         :lifecycle_environment =>  katello_environments(:library))
    end

    let(:status) { host.get_status(Katello::ErrataStatus) }

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
    end

    def test_to_status_no_repos
      assert_equal Katello::ErrataStatus::UNKNOWN, status.to_status
    end

    def test_to_status_repos_no_errata
      host.content_facet.bound_repositories << repo
      assert_equal Katello::ErrataStatus::UP_TO_DATE, status.to_status
    end

    def test_no_content_facet
      assert_equal Katello::ErrataStatus::UNKNOWN, FactoryGirl.build(:host).get_status(Katello::ErrataStatus).to_status
    end

    def test_to_global
      status.status = Katello::ErrataStatus::UNKNOWN
      assert_equal HostStatus::Global::WARN, status.to_global
    end
  end
end
