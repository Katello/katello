require 'katello_test_helper'

module Katello
  class ErrataListPresenterTest < ActiveSupport::TestCase
    def test_reports_preloaded_details
      erratum = katello_errata(:modular)
      details = ErrataListDetails.load(Katello::Erratum, [erratum])
      presenter = ErrataListPresenter.new(erratum, details)

      assert_equal details.package_nvreas(erratum.id), presenter.package_nvreas
      assert_equal details.module_streams(erratum.id), presenter.module_streams
      assert_equal details.hosts_applicable_count(erratum.id), presenter.hosts_applicable_count
      assert_equal details.hosts_available_count(erratum.id), presenter.hosts_available_count
      assert_equal erratum.title, presenter.title
    end
  end
end
