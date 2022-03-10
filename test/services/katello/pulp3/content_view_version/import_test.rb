require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportTest < ActiveSupport::TestCase
          let(:cv) { @cv || katello_content_views(:import_only_view) }

          let(:org) { @org || cv.organization }

          let(:metadata_map) do
            stub('metadata_map',
                 repositories: @metadata_repos,
                 products: @metadata_products,
                 content_view: @metadata_cv
                )
          end

          let(:import) do
            Katello::Pulp3::ContentViewVersion::Import.new(
              organization: org,
              path: @path,
              smart_proxy: @smart_proxy,
              metadata_map: metadata_map
            )
          end

          it "Import correctly resets content view repositories from metadata" do
            prior_repository_ids = cv.repository_ids
            repo = katello_repositories(:rhel_7_x86_64)

            @metadata_cv = stub('metadata cv', name: cv.name, label: cv.label, description: cv.description, generated_for: 'none')
            metadata_product = stub('metadata_product', label: repo.product.label, name: repo.product.name, cp_id: repo.product.cp_id)
            @metadata_repos = [
              stub('metadata repo', label: repo.label, product: metadata_product, redhat: repo.redhat?)
            ]

            import.reset_content_view_repositories!

            cv.reload
            refute_equal prior_repository_ids, cv.repository_ids
            assert_equal cv.repository_ids, [repo.id]
          end

          it "Fetches the intersecting custom repos without cp_id" do
            repo = katello_repositories(:feedless_fedora_17_x86_64)

            @metadata_cv = stub('metadata cv', name: cv.name, label: cv.label, description: cv.description, generated_for: 'none')
            metadata_product = stub('metadata_product', label: repo.product.label, cp_id: nil)
            @metadata_repos = [
              stub('library repo', label: repo.label, product: metadata_product, redhat: false),
              stub('non-library repo', label: "unknown-007", product: metadata_product, redhat: false)
            ]

            repos = import.intersecting_repos_library_and_metadata

            assert_equal [repo.id], repos.pluck(:id)
          end

          it "Fetches the intersecting redhat repos with cp_id" do
            repo = katello_repositories(:rhel_7_x86_64)

            @metadata_cv = stub('metadata cv', name: cv.name, label: cv.label, description: cv.description, generated_for: 'none')
            metadata_product = stub('metadata_product', label: repo.product.label, cp_id: repo.product.cp_id)
            @metadata_repos = [
              stub('library repo', label: repo.label, product: metadata_product, redhat: true),
              stub('non-library repo', label: "unknown-007", product: metadata_product, redhat: true)
            ]

            repos = import.intersecting_repos_library_and_metadata

            assert_equal [repo.id], repos.pluck(:id)
          end

          it "should fail to import  cv if label is not specified" do
            @metadata_cv = stub(label: nil, name: 'fake')

            exception = assert_raises(RuntimeError) do
              import
            end

            assert_match(/label not provided/, exception.message)
          end

          it "should fail to import cv if import_only is false" do
            cv = katello_content_views(:library_view)
            refute cv.import_only?
            @metadata_cv = stub(name: 'fake', label: cv.label, description: 'fake', generated_for: :none)

            exception = assert_raises(RuntimeError) do
              import
            end

            assert_match(/foreman-rake katello:set_content_view_import_only ID=/, exception.message)
          end

          it "should create an importable content view" do
            @org = katello_content_views(:library_view).organization
            label = "Export-GREAT_REPO10000"
            @metadata_cv = stub(label: label, name: label, description: 'fake', generated_for: 'repository_export')

            cv = import.content_view

            assert_equal cv.label, "Import-GREAT_REPO10000"
            assert_equal cv.organization, @org
            assert cv.import_only?
          end

          it "should create an importable content view for library" do
            @metadata_cv = stub(name: ::Katello::ContentView::EXPORT_LIBRARY,
                                         label: ::Katello::ContentView::EXPORT_LIBRARY,
                                         generated_for: :library_export)

            cv = import.content_view

            assert_equal cv.label, ::Katello::ContentView::IMPORT_LIBRARY
            assert_equal cv.organization, org
            assert cv.import_only?
            assert cv.generated_for_library_import?
          end

          it "should create an importable content view for library with no generated_for" do
            @metadata_cv = stub(name: ::Katello::ContentView::EXPORT_LIBRARY, label: ::Katello::ContentView::EXPORT_LIBRARY, generated_for: '')

            cv = import.content_view

            assert_equal cv.label, ::Katello::ContentView::IMPORT_LIBRARY
            assert_equal cv.organization, org
            assert cv.import_only?
            assert cv.generated_for_library_import?
          end

          it "should create the import name for generated content" do
            @metadata_cv = stub(name: "Export-Repository", label: "Export-Repository", generated_for: :repository_export)

            cv = import.content_view

            assert_equal cv.label, "Import-Repository"
            assert_equal cv.organization, org
            assert cv.import_only?
            assert cv.generated_for_repository_import?
          end
        end
      end
    end
  end
end
