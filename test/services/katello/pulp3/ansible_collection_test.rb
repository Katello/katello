require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      class AnsibleCollectionTest < ActiveSupport::TestCase
        def test_generate_model_row
          json = {
            'pulp_href' => '/pulp/api/v3/content/ansible/collection_versions/abc/',
            'prn' => 'prn:ansible.collectionversion:abc',
            'sha256' => 'deadbeef',
            'namespace' => 'community',
            'name' => 'general',
            'version' => '1.2.3',
            'description' => 'General community modules',
          }.with_indifferent_access

          row = ::Katello::Pulp3::AnsibleCollection.generate_model_row(json)

          assert_equal json['pulp_href'], row[:pulp_id]
          assert_equal json['prn'], row[:pulp_prn]
          assert_equal json['sha256'], row[:checksum]
          assert_equal json['namespace'], row[:namespace]
          assert_equal json['name'], row[:name]
          assert_equal json['version'], row[:version]
          assert_equal json['description'], row[:description]
        end

        def test_indexed_fields_match_what_the_indexer_consumes
          service = ::Katello::Pulp3::AnsibleCollection

          assert_equal %w(sha256 namespace name version description tags), service::SPECIFIC_INDEXED_FIELDS
          assert_equal %w(pulp_href prn), service::COMMON_INDEXED_FIELDS
          assert_equal %w(pulp_href prn sha256 namespace name version description tags), service.indexed_fields
        end

        def test_indexing_requests_only_indexed_fields
          service = ::Katello::Pulp3::AnsibleCollection
          repo = mock
          repo.stubs(:version_href).returns('/pulp/api/v3/repositories/ansible/ansible/abc/versions/1/')
          repo.stubs(:generic?).returns(false)

          captured = nil
          # The assignment returns the hash (truthy), so the matcher both captures and matches.
          service.stubs(:fetch_content_list).with { |page_opts| captured = page_opts }.returns('count' => 0, 'results' => [])

          service.pulp_units_batch_for_repo(repo).each { |_batch| }

          assert_equal service.indexed_fields.join(','), captured[:fields]
          refute_includes captured[:fields].split(','), 'docs_blob'
        end
      end
    end
  end
end
