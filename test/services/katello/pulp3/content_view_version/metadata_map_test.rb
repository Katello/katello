require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class MetadataMapTest < ActiveSupport::TestCase
          def test_parse_metadata_pre_cp_id
            # original export metadata without cp_id on products

            metadata = File.read(File.open(Katello::Engine.root.join('test/fixtures/import-export/metadata_complete_library.json')))
            metadata_hash = JSON.parse(metadata).with_indifferent_access

            map = Katello::Pulp3::ContentViewVersion::MetadataMap.new(metadata: metadata_hash)

            assert map.toc
            assert map.content_view
            assert map.content_view_version
            refute map.from_content_view_version
            assert_equal 3, map.products.length
            assert_equal 4, map.repositories.size
            assert_empty map.gpg_keys
          end

          def test_parse_metadata_post_cp_id
            metadata = File.read(File.open(Katello::Engine.root.join('test/fixtures/import-export/metadata_incremental_cp_id.json')))
            metadata_hash = JSON.parse(metadata).with_indifferent_access

            map = Katello::Pulp3::ContentViewVersion::MetadataMap.new(metadata: metadata_hash)

            assert map.toc
            assert map.content_view
            assert map.content_view_version
            assert map.from_content_view_version
            assert_equal 2, map.products.length
            assert_equal 4, map.repositories.size
            assert_empty map.gpg_keys
          end
        end
      end
    end
  end
end
