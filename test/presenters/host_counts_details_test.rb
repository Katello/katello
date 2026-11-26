require 'katello_test_helper'

module Katello
  class HostCountsDetailsTest < ActiveSupport::TestCase
    def test_matches_per_record_queries
      erratum = katello_errata(:security)
      details = HostCountsDetails.load(Katello::Erratum, [erratum])

      assert_equal erratum.hosts_applicable.count, details.hosts_applicable_count(erratum.id)
      assert_equal erratum.hosts_available.count, details.hosts_available_count(erratum.id)
    end

    def test_wrap_returns_presenters
      records = [katello_errata(:security)]

      wrapped = HostCountsDetails.wrap(Katello::Erratum, records)

      assert wrapped.first.is_a?(HostCountsPresenter)
      assert_equal records.first.id, wrapped.first.id
      assert_equal records.first.title, wrapped.first.title
    end

    def test_wrap_returns_records_when_counts_are_unavailable
      records = [katello_module_streams(:one)]

      assert_equal records, HostCountsDetails.wrap(Katello::ModuleStream, records)
    end

    def test_empty_page
      details = HostCountsDetails.load(Katello::Erratum, [])

      assert_equal 0, details.hosts_applicable_count(1)
      assert_equal 0, details.hosts_available_count(1)
    end
  end
end
