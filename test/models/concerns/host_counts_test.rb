require 'katello_test_helper'

module Katello
  class HostCountsTest < ActiveSupport::TestCase
    def setup
      @host = hosts(:one)
      @erratum = katello_errata(:security)
    end

    def test_applicable_host_facets_returns_content_facets_with_hosts
      facets = Katello::Erratum.applicable_host_facets([@erratum.id])

      refute_empty facets
      assert(facets.all? { |facet| facet.is_a?(Katello::Host::ContentFacet) })
      assert_includes facets, @host.content_facet
      assert_equal @host, facets.detect { |facet| facet.id == @host.content_facet.id }.host
    end

    def test_applicable_host_facets_filter_by_organization
      other_organization_id = Organization.maximum(:id).to_i + 1

      assert_empty Katello::Erratum.applicable_host_facets([@erratum.id], other_organization_id)
    end

    def test_available_host_facets_require_a_bound_repository
      @host.content_facet.bound_repositories += @erratum.repositories
      @host.content_facet.save!

      facets = Katello::Erratum.available_host_facets([@erratum.id]).to_a

      assert_equal [@host.content_facet], facets
    end

    def test_available_host_facets_are_counted_once_per_facet
      @host.content_facet.bound_repositories += [
        katello_repositories(:rhel_6_x86_64),
        katello_repositories(:fedora_17_x86_64),
      ]
      @host.content_facet.save!

      assert_equal 1, Katello::Erratum.available_host_facets([@erratum.id]).to_a.size
      assert_equal 1, Katello::Erratum.available_host_counts([@erratum.id])[@erratum.id]
    end

    def test_available_host_facets_skip_facets_bound_to_other_repositories
      @host.content_facet.bound_repositories += [katello_repositories(:fedora_17_x86_64_dev)]
      @host.content_facet.save!

      assert_includes Katello::Erratum.applicable_host_facets([@erratum.id]), @host.content_facet
      assert_empty Katello::Erratum.available_host_facets([@erratum.id])
      assert_equal 0, Katello::Erratum.available_host_counts([@erratum.id]).fetch(@erratum.id, 0)
    end

    def test_batched_counts_match_per_record_counts
      @host.content_facet.bound_repositories += @erratum.repositories
      @host.content_facet.save!

      applicable = Katello::Erratum.applicable_host_counts([@erratum.id])
      available = Katello::Erratum.available_host_counts([@erratum.id])

      assert_equal @erratum.hosts_applicable.count, applicable.fetch(@erratum.id, 0)
      assert_equal @erratum.hosts_available.count, available.fetch(@erratum.id, 0)
    end

    def test_batched_counts_span_id_batches
      ids = [@erratum.id, katello_errata(:bugfix).id]
      expected = Katello::Erratum.applicable_host_counts(ids)

      stub_constant(Katello::Util::IdBatches, :MAX_IDS, 1) do
        assert_equal expected, Katello::Erratum.applicable_host_counts(ids)
      end
    end

    def test_empty_unit_ids
      assert_empty Katello::Erratum.applicable_host_facets([])
      assert_empty Katello::Erratum.available_host_facets([])
      assert_empty Katello::Erratum.applicable_host_counts([])
      assert_empty Katello::Erratum.available_host_counts([])
    end

    def test_instance_methods_keep_the_relation_contract
      assert_kind_of ActiveRecord::Relation, @erratum.hosts_applicable
      assert_kind_of ActiveRecord::Relation, @erratum.hosts_available
    end
  end
end
