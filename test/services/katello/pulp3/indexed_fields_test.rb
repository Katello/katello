require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      class IndexedFieldsTest < ActiveSupport::TestCase
        # Only what each indexer reads beyond PulpContentUnit::COMMON_INDEXED_FIELDS.
        EXPECTED_SPECIFIC_FIELDS = {
          ::Katello::Pulp3::AnsibleCollection => %w(sha256 namespace name version description tags),
          ::Katello::Pulp3::DockerManifest => %w(digest schema_version annotations labels is_bootable is_flatpak type),
          ::Katello::Pulp3::DockerManifestList => %w(digest schema_version annotations labels is_bootable is_flatpak type listed_manifests),
          ::Katello::Pulp3::DockerTag => %w(name tagged_manifest),
          ::Katello::Pulp3::FileUnit => %w(relative_path sha256),
          ::Katello::Pulp3::PackageGroup => %w(name description),
          ::Katello::Pulp3::Rpm => %w(name version release arch epoch summary is_modular rpm_sourcerpm location_href pkgId),
          ::Katello::Pulp3::Srpm => %w(name version release arch epoch summary location_href pkgId),
        }.freeze

        def test_common_fields_are_shared_by_every_filtering_type
          assert_equal %w(pulp_href prn), ::Katello::Pulp3::PulpContentUnit::COMMON_INDEXED_FIELDS
        end

        def test_specific_fields_are_composed_with_the_common_ones
          EXPECTED_SPECIFIC_FIELDS.each do |service, specific|
            assert_equal specific, service::SPECIFIC_INDEXED_FIELDS, service.name
            assert_equal ::Katello::Pulp3::PulpContentUnit::COMMON_INDEXED_FIELDS + specific,
              service.indexed_fields, service.name
          end
        end

        def test_specific_fields_do_not_repeat_the_common_ones
          EXPECTED_SPECIFIC_FIELDS.each do |service, specific|
            assert_empty specific & ::Katello::Pulp3::PulpContentUnit::COMMON_INDEXED_FIELDS, service.name
          end
        end

        def test_list_requests_carry_the_indexed_fields
          EXPECTED_SPECIFIC_FIELDS.each_key do |service|
            repo = mock
            repo.stubs(:version_href).returns('/pulp/api/v3/repositories/x/y/abc/versions/1/')
            repo.stubs(:generic?).returns(false)

            captured = nil
            service.stubs(:fetch_content_list).with { |page_opts| captured = page_opts }.returns('count' => 0, 'results' => [])

            service.pulp_units_batch_for_repo(repo).each { |_batch| }

            assert_equal service.indexed_fields.join(','), captured[:fields], service.name
          end
        end

        def test_types_without_a_field_list_keep_the_full_response
          assert_nil ::Katello::Pulp3::Erratum.indexed_fields
        end
      end
    end
  end
end
