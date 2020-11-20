require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures

          it "Import correctly resets content_view_repositories from metadata" do
            cv = katello_content_views(:library_view)
            prior_repository_ids = cv.repository_ids
            repo = katello_repositories(:rhel_7_x86_64)
            metadata = { content_view: cv.name,
                         repository_mapping: {
                           "misc-24037": { "repository": repo.name,
                                           "product": repo.product.name,
                                           "redhat": repo.redhat?
                                         }
                         }
            }.with_indifferent_access

            Katello::Pulp3::ContentViewVersion::Import.reset_content_view_repositories_from_metadata!(content_view: cv, metadata: metadata)
            refute_equal prior_repository_ids, cv.repository_ids
            assert_equal cv.repository_ids, [repo.id]
          end
        end
      end
    end
  end
end
