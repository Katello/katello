require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportValidatorTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures

          def validator(content_view: nil, path: nil, metadata: {}, smart_proxy: nil)
            smart_proxy ||= smart_proxies(:one)
            content_view ||= katello_content_views(:acme_default)
            ::Katello::Pulp3::ContentViewVersion::ImportValidator.new(
                                                        content_view: content_view,
                                                        path: path,
                                                        metadata: metadata,
                                                        smart_proxy: smart_proxy)
          end

          describe "Metadata" do
            it "fails on pulp error" do
              cvv = katello_content_view_versions(:library_view_version_2)
              invalid_message = "Pulp error!"
              toc = mock(is_valid: false, messages: [invalid_message])
              response = mock
              response.expects(:toc).returns(toc).at_least_once
              api = mock
              api.expects(:pulp_import_check_post).returns(response)

              ::Katello::Pulp3::Api::Core.
                any_instance.
                expects(:importer_check_api).
                returns(api)

              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cvv.content_view.slice(:name, :label, :description), content_view_version: cvv.slice(:major, :minor) }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_equal(invalid_message, exception.message)
            end

            it "fails on metadata if content view already exists" do
              cvv = katello_content_view_versions(:library_view_version_2)
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:ensure_pulp_importable!).returns
              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cvv.content_view.slice(:name, :label, :description), content_view_version: cvv.slice(:major, :minor) }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/already exists/, exception.message)
            end

            it "fails on metadata if from content view does not exist" do
              cvv = katello_content_view_versions(:library_view_version_2)
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:ensure_pulp_importable!).returns

              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cvv.content_view.slice(:name, :label, :description),
                             content_view_version: { major: cvv.major + 10, minor: cvv.minor },
                             from_content_view_version: { major: cvv.major + 8, minor: cvv.minor }
                }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/ does not exist/, exception.message)
            end

            it "fails on metadata if repo types in metadata dont match the repos in library" do
              cvv = katello_content_view_versions(:library_view_version_2)
              repo = cvv.repositories.exportable.last
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:ensure_manifest_imported!).returns
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:ensure_pulp_importable!).returns

              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cvv.content_view.slice(:name, :label, :description),
                             content_view_version: { major: cvv.major + 10, minor: cvv.minor },
                             products: {
                               repo.product.label => repo.product.slice(:name, :label).merge(redhat: !repo.redhat?)
                             },
                             repositories: {
                               "misc-24037": { label: repo.label,
                                               product: { name: repo.product.name, label: repo.product.label},
                                               redhat: !repo.redhat?
                                             }
                             },
                             gpg_keys: {}
                }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/incorrect content type or provider type/, exception.message)
            end

            it "fails on import if manifest is not imported" do
              cv = katello_content_views(:acme_default)
              cvv = cv.versions.last
              org = cv.organization
              org.stubs(:manifest_imported?).returns(false)

              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cv.slice(:name, :label, :description),
                             content_view_version: { major: cvv.major + 10, minor: cvv.minor },
                             products: {
                               "prod" => { name: "prod", label: 'prod'}
                             },
                             gpg_keys: {},
                             repositories: {
                               "misc-24037": { label: "misc",
                                               product: {label: 'prod'},
                                               "redhat": true
                                             }
                             }
                }
                validator(content_view: cvv.content_view, metadata: metadata).ensure_manifest_imported!
              end
              assert_match(/No manifest found. Import a manifest with the appropriate subscriptions before importing content./, exception.message)
            end

            it "fails on metadata if redhat products in the metadata are not in the library" do
              cv = katello_content_views(:acme_default)
              cvv = cv.versions.last
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:ensure_manifest_imported!).returns
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:ensure_pulp_importable!).returns

              exception = assert_raises(RuntimeError) do
                metadata = { content_view: cv.slice(:name, :label, :description),
                             content_view_version: { major: cvv.major + 10, minor: cvv.minor },
                             products: {
                               "prod" => { name: "prod", label: 'prod'},
                               "redhat_label" => { name: 'Red Hat Linux', label: 'redhat_label'}
                             },
                             gpg_keys: {},
                             repositories: {
                               "misc-24037": { label: "misc",
                                               product: {label: 'prod'},
                                               "redhat": true
                                             },
                               "rhel-7": { label: "rhel_7",
                                           product: {label: 'redhat_label'},
                                           "redhat": true
                                }
                             }
                }
                validator(content_view: cvv.content_view, metadata: metadata).check!
              end
              assert_match(/The organization's manifest does not contain the subscriptions required to enable the following repositories./, exception.message)
              assert_match(/prod/, exception.message)
              refute_match(/redhat_label/, exception.message)
            end
          end
        end
      end
    end
  end
end
