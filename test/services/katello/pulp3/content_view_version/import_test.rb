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
                         products: {
                           repo.product.label => repo.product.slice(:name, :label)
                         },
                         repositories: {
                           "misc-24037": { "label": repo.label,
                                           "product": { label: repo.product.label },
                                           "redhat": repo.redhat?
                                         }
                         }
            }.with_indifferent_access

            Katello::Pulp3::ContentViewVersion::Import.reset_content_view_repositories_from_metadata!(content_view: cv, metadata: metadata)
            refute_equal prior_repository_ids, cv.repository_ids
            assert_equal cv.repository_ids, [repo.id]
          end

          it "Fetches the and updates gpgkeys correctly" do
            org = get_organization
            gpg_key = "MyCoolKey10000"
            existing_gpgkey = katello_gpg_keys(:fedora_gpg_key)
            updated_content = "#{existing_gpgkey.content} additional content!"

            Katello::Pulp3::ContentViewVersion::Import.create_or_update_gpg!(
                organization: org,
                params: { name: existing_gpgkey.name, content: updated_content }
            )

            assert_equal updated_content, org.gpg_keys.find_by(name: existing_gpgkey.name).content

            Katello::Pulp3::ContentViewVersion::Import.create_or_update_gpg!(
                organization: org,
                params: { name: gpg_key, content: "wow" }
            )
            refute_nil org.gpg_keys.find_by(name: gpg_key)
          end

          it "Fetches the intersecting repos correctly" do
            org = get_organization
            repo = katello_repositories(:feedless_fedora_17_x86_64)
            repos = Katello::Pulp3::ContentViewVersion::Import.intersecting_repos_library_and_metadata(
                  organization: org,
                  metadata: {
                    products: {
                      repo.product.label => repo.product.slice(:name, :label)
                    },
                    gpg_keys: {},
                    repositories: {
                      foo: { label: repo.label,
                             product: repo.product.slice(:label)
                      },
                      unknown: { label: "#{repo.label}-unknown-007",
                                 product: repo.product.slice(:label)
                      }
                    }
                  }.with_indifferent_access
              )

            assert_equal [repo.id], repos.pluck(:id)
          end

          it "Fetches the metadata map correctly" do
            repo = katello_repositories(:fedora_17_x86_64)
            unknown = "#{repo.label}-unknown-007"
            metadata_map = Katello::Pulp3::ContentViewVersion::Import.metadata_map({
              products: {
                repo.product.label => repo.product.slice(:name, :label)
              },
              gpg_keys: {},
              repositories: {
                foo: { label: repo.label,
                       product: repo.product.slice(:label),
                       redhat: true
                },
                unknown: { label: unknown,
                           product: repo.product.slice(:label),
                           redhat: false
                      }
              }
            }.with_indifferent_access
            )

            refute_empty metadata_map[[repo.product.label, repo.label]]
            assert metadata_map[[repo.product.label, repo.label]][:redhat]

            refute_empty metadata_map[[repo.product.label, unknown]]
            refute metadata_map[[repo.product.label, unknown]][:redhat]
          end

          it "should fail to import  cv if label is not specified" do
            org = katello_content_views(:library_view).organization
            exception = assert_raises(RuntimeError) do
              ::Katello::Pulp3::ContentViewVersion::Import.
                    find_or_create_import_view(organization: org,
                                                metadata: {})
            end
            assert_match(/label not provided/, exception.message)
          end

          it "should fail to import cv if import_only is false" do
            cv = katello_content_views(:library_view)
            refute cv.import_only?
            exception = assert_raises(RuntimeError) do
              ::Katello::Pulp3::ContentViewVersion::Import.
                    find_or_create_import_view(organization: cv.organization,
                                                metadata: { label: cv.label,
                                                            generated_for: :none }.with_indifferent_access)
            end
            assert_match(/foreman-rake katello:set_content_view_import_only ID=/, exception.message)
          end

          it "should create an importable content view" do
            org = katello_content_views(:library_view).organization
            label = "Export-GREAT_REPO10000"
            cv = ::Katello::Pulp3::ContentViewVersion::Import.
                    find_or_create_import_view(organization: org,
                                                metadata: { label: label,
                                                            name: label,
                                                            generated_for: :repository_export }.with_indifferent_access)
            assert_equal cv.label, "Import-GREAT_REPO10000"
            assert_equal cv.organization, org
            assert cv.import_only?
          end

          it "should create an importable content view for library" do
            org = katello_content_views(:library_view).organization
            cv = ::Katello::Pulp3::ContentViewVersion::Import.
                    find_or_create_import_view(organization: org,
                                                metadata: { name: ::Katello::ContentView::EXPORT_LIBRARY,
                                                            label: ::Katello::ContentView::EXPORT_LIBRARY,
                                                            generated_for: :library_export })
            assert_equal cv.label, ::Katello::ContentView::IMPORT_LIBRARY
            assert_equal cv.organization, org
            assert cv.import_only?
            assert cv.generated_for_library_import?
          end

          it "should create an importable content view for library with no generated_for" do
            org = katello_content_views(:library_view).organization
            cv = ::Katello::Pulp3::ContentViewVersion::Import.
                    find_or_create_import_view(organization: org,
                                                metadata: { name: ::Katello::ContentView::EXPORT_LIBRARY,
                                                            label: ::Katello::ContentView::EXPORT_LIBRARY})
            assert_equal cv.label, ::Katello::ContentView::IMPORT_LIBRARY
            assert_equal cv.organization, org
            assert cv.import_only?
            assert cv.generated_for_library_import?
          end

          it "should create the import name for generated content" do
            org = katello_content_views(:library_view).organization
            destination_server = "Foo"
            cv = ::Katello::Pulp3::ContentViewVersion::Import.
                    find_or_create_import_view(organization: org,
                                                metadata: { name: "Export-Repository-#{destination_server}",
                                                            label: "Export-Repository-#{destination_server}",
                                                            generated_for: :repository_export,
                                                            destination_server: "Foo" })
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
