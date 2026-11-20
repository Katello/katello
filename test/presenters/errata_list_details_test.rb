require 'katello_test_helper'

module Katello
  class ErrataListDetailsTest < ActiveSupport::TestCase
    def test_matches_per_record_queries
      records = [katello_errata(:security), katello_errata(:modular), katello_errata(:bugfix)]
      details = ErrataListDetails.load(Katello::Erratum, records)
      expected_stream_names = {
        katello_errata(:security).id => [],
        katello_errata(:modular).id => ['three'],
        katello_errata(:bugfix).id => [],
      }

      records.each do |record|
        expected_nvreas = record.packages.non_module_stream_packages.pluck(:nvrea)
        stream_names = details.module_streams(record.id).map { |stream| stream[:name] }.sort

        assert_equal expected_nvreas.sort, details.package_nvreas(record.id).sort,
                     "packages for erratum #{record.id}"
        assert_equal expected_stream_names.fetch(record.id), stream_names,
                     "module streams for erratum #{record.id}"
      end
    end

    def test_fixture_payload
      details = ErrataListDetails.load(Katello::Erratum, [katello_errata(:security), katello_errata(:modular)])

      assert_equal ['foobar-1.2.3'], details.package_nvreas(katello_errata(:security).id)
      assert_empty details.module_streams(katello_errata(:security).id)

      modular_streams = details.module_streams(katello_errata(:modular).id)
      assert_empty details.package_nvreas(katello_errata(:modular).id)
      names = modular_streams.map { |stream| stream[:name] }
      nvreas = modular_streams.flat_map { |stream| stream[:packages] }
      assert_equal ['three'], names
      assert_equal ['foobarmod-1.2.3'], nvreas
    end

    def test_groups_module_stream_packages_by_erratum
      erratum = Katello::Erratum.create!(:pulp_id => 'erratum-with-modular-package')
      package = Katello::ErratumPackage.create!(:erratum => erratum, :name => 'foo', :nvrea => 'foo-1.0-1',
                                                :filename => 'foo-1.0-1.rpm')
      Katello::ModuleStreamErratumPackage.create!(:module_stream => katello_module_streams(:three),
                                                  :erratum_package => package)

      details = ErrataListDetails.load(Katello::Erratum, [erratum])

      nvreas = details.module_streams(erratum.id).flat_map { |stream| stream[:packages] }
      assert_equal ['foo-1.0-1'], nvreas
    end

    def test_wrap_returns_errata_presenters
      records = [katello_errata(:modular)]

      wrapped = ErrataListDetails.wrap(Katello::Erratum, records)
      names = wrapped.first.module_streams.map { |stream| stream[:name] }

      assert wrapped.first.is_a?(ErrataListPresenter)
      assert_equal ['three'], names
    end

    def test_empty_page
      details = ErrataListDetails.load(Katello::Erratum, [])

      assert_empty details.package_nvreas(1)
      assert_empty details.module_streams(1)
      assert_equal 0, details.hosts_applicable_count(1)
      assert_equal 0, details.hosts_available_count(1)
    end

    def test_batches_span_id_batches
      modular = katello_errata(:modular)
      security = katello_errata(:security)

      stub_constant(Katello::Util::IdBatches, :MAX_IDS, 1) do
        details = ErrataListDetails.load(Katello::Erratum, [modular, security])
        names = details.module_streams(modular.id).map { |stream| stream[:name] }

        assert_equal ['foobar-1.2.3'], details.package_nvreas(security.id)
        assert_equal ['three'], names
      end
    end
  end
end
