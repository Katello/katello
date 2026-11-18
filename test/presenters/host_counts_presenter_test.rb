require 'katello_test_helper'

module Katello
  class HostCountsPresenterTest < ActiveSupport::TestCase
    def test_reports_preloaded_details
      erratum = katello_errata(:security)
      details = HostCountsDetails.load(Katello::Erratum, [erratum])
      presenter = HostCountsPresenter.new(erratum, details)

      assert_equal details.hosts_applicable_count(erratum.id), presenter.hosts_applicable_count
      assert_equal details.hosts_available_count(erratum.id), presenter.hosts_available_count
      assert_equal erratum.title, presenter.title
    end
  end
end
