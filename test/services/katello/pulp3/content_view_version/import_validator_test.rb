require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportValidatorTest < ActiveSupport::TestCase
          let(:cvv) { katello_content_view_versions(:library_view_version_2) }

          let(:import) do
            @content_view ||= katello_content_views(:acme_default)
            @metadata_cv ||= stub('metadata_cv')
            @metadata_repos ||= []
            @metadata_products ||= []

            metadata_map = stub('metadata map',
                 toc: '/tmp',
                 content_view: @metadata_cv,
                 content_view_version: @metadata_cvv,
                 from_content_view_version: @metadata_from_cvv,
                 products: @metadata_products,
                 repositories: @metadata_repos,
                 syncable_format?: false
           )

            stub('import',
              organization: @content_view.organization,
              content_view: @content_view,
              path: '/var/lib/pulp/exports',
              metadata_map: metadata_map,
              intersecting_repos_library_and_metadata: @intersecting_repos,
              smart_proxy: @smart_proxy || smart_proxies(:one)
            )
          end

          let(:validator) do
            ::Katello::Pulp3::ContentViewVersion::ImportValidator.new(import: import)
          end

          describe "Metadata" do
            it "fails on pulp error" do
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
                validator.check!
              end

              assert_equal(invalid_message, exception.message)
            end

            it "fails on metadata if content view already exists" do
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:ensure_pulp_importable!).returns
              @metadata_cvv = stub('metadata cvv', major: cvv.major, minor: cvv.minor)
              @content_view = cvv.content_view
              exception = assert_raises(RuntimeError) do
                validator.check!
              end
              assert_match(/already exists/, exception.message)
            end

            it "fails on metadata if from content view does not exist" do
              ::Katello::Pulp3::ContentViewVersion::ImportValidator.any_instance.expects(:ensure_pulp_importable!).returns

              @content_view = cvv.content_view
              @metadata_cvv = stub('metadata cvv', major: cvv.major + 10, minor: cvv.minor)
              @metadata_from_cvv = stub('metadata from cvv', major: cvv.major + 8, minor: cvv.minor)
              exception = assert_raises(RuntimeError) do
                validator.check!
              end
              assert_match(/ does not exist/, exception.message)
            end

            it "fails on metadata if repo types in metadata dont match the repos in library" do
              repo = cvv.repositories.exportable.last
              metadata_product = stub('metadata product',
                                      name: repo.product.name,
                                      label: repo.product.label,
                                      cp_id: nil,
                                      redhat: !repo.redhat?)
              @metadata_repos = [
                stub('metadata repo',
                     name: repo.name,
                     label: repo.label,
                     product: metadata_product,
                     content_type: 'bogus',
                     redhat: !repo.redhat?)
              ]

              @intersecting_repos = [repo]

              exception = assert_raises(RuntimeError) do
                validator.ensure_metadata_matches_repos_in_library!
              end
              assert_match(/incorrect content type or provider type/, exception.message)
            end

            it "fails on import if manifest is not imported" do
              org = cvv.content_view.organization
              org.stubs(:manifest_imported?).returns(false)

              @content_view = cvv.content_view
              @metadata_repos = [
                stub('metadata repo', redhat: true)
              ]

              exception = assert_raises(RuntimeError) do
                validator.ensure_manifest_imported!
              end
              assert_match(/No manifest found. Import a manifest with the appropriate subscriptions before importing content./, exception.message)
            end

            it "fails on metadata if redhat products in the metadata are not in the library" do
              @metadata_products = [
                stub('product', redhat: false, name: 'prod', label: 'prod', cp_id: nil),
                stub('red hat product', redhat: true, name: 'Red Hat Linux', label: 'rhel_7', cp_id: nil)
              ]

              @metadata_repos = [
                stub('metadata repo', name: "misc", label: "misc", redhat: true, product: @metadata_products.first),
                stub('metadata repo', name: "rhel_7", label: "rhel_7", redhat: true, product: @metadata_products.second)
              ]

              exception = assert_raises(RuntimeError) do
                validator.ensure_redhat_products_metadata_are_in_the_library!
              end
              assert_match(/The organization's manifest does not contain the subscriptions required to enable the following repositories./, exception.message)
              assert_match(/prod/, exception.message)
              refute_match(/redhat_label/, exception.message)
            end
          end

          it "can validate Red Hat repositories based on their cp_id" do
            @metadata_products = [
              stub('product', redhat: false, name: 'prod', label: 'prod', cp_id: '83'),
              stub('red hat product', redhat: true, name: 'Red Hat Linux', label: 'rhel_7', cp_id: '69')
            ]

            @content_view = cvv.content_view
            @metadata_repos = [
              stub('metadata repo', name: "misc", label: "misc", redhat: true, product: @metadata_products.first),
              stub('metadata repo', name: "rhel_7", label: "rhel_7", redhat: true, product: @metadata_products.second)
            ]

            exception = assert_raises(RuntimeError) do
              validator.ensure_redhat_products_metadata_are_in_the_library!
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
