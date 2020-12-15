require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportValidatorTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures

          def validator(content_view: nil, path: nil, metadata: {})
            content_view ||= katello_content_views(:acme_default)
            ::Katello::Pulp3::ContentViewVersion::ImportValidator.new(
                                                        content_view: content_view,
                                                        path: path,
                                                        metadata: metadata)
          end

          describe "Metadata" do
            it "fails on metadata if content view already exists" do
              cvv = katello_content_view_versions(:library_view_version_2)
              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cvv.content_view.name, content_view_version: cvv.slice(:major, :minor) }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/already exists/, exception.message)
            end

            it "fails on metadata if from content view does not exist" do
              cvv = katello_content_view_versions(:library_view_version_2)
              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cvv.content_view.name,
                             content_view_version: { major: cvv.major + 10, minor: cvv.minor },
                             from_content_view_version: { major: cvv.major + 8, minor: cvv.minor }
                }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/ does not exist/, exception.message)
            end

            it "fails on metadata if the repositories in the metadata are not in the library" do
              cv = katello_content_views(:acme_default)
              cvv = cv.versions.last
              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cv.name,
                             content_view_version: { major: cvv.major + 10, minor: cvv.minor },
                             repository_mapping: {
                               "misc-24037": { "repository": "misc",
                                               "product": "prod",
                                               "redhat": false
                                             }
                             }
                }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/repositories provided in the import metadata are either not available in the Library or are of incorrect Respository Type./, exception.message)
            end
          end
        end
      end
    end
  end
end
