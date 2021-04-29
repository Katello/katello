require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportableRepositoriesTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures

          it "Fetches the right repos to auto create" do
            repo = katello_repositories(:fedora_17_x86_64)
            new_repo_1 = "New-Repo-1"
            new_repo_2 = "New-Repo-2"
            gpg_key = katello_gpg_keys(:fedora_gpg_key)
            product_label = repo.product.label
            metadata = {
              products: {
                product_label => { label: product_label }
              },
              repositories: {
                "misc-24037": { "label": repo.label,
                                "product": { label: product_label },
                                "redhat": repo.redhat?
                              },
                "hoo-24037": { "label": new_repo_1,
                               "product": { label: product_label },
                               "redhat": false
                              },
                "hah-24037": { "label": new_repo_2,
                               "product": { label: product_label },
                               "redhat": false,
                               "gpg_key": { name: gpg_key.name }
                              }
              },
              gpg_keys: {
                gpg_key => gpg_key.slice(:name, :content)
              }
            }.with_indifferent_access
            helper = Katello::Pulp3::ContentViewVersion::ImportableRepositories.
                      new(organization: repo.organization, metadata: metadata)
            helper.generate!

            assert_includes helper.creatable.map { |r| r[:repository].label }, new_repo_1
            assert_includes helper.creatable.map { |r| r[:repository].label }, new_repo_2
            refute_includes helper.creatable.map { |r| r[:repository].label }, repo.label
            assert_includes helper.updatable.map { |r| r[:repository].label }, repo.label
            refute_includes helper.updatable.map { |r| r[:repository].label }, new_repo_1

            refute_nil repo.organization.gpg_keys.find_by(name: gpg_key.name)
          end

          it "Fetches the right repos to enable" do
            repo = katello_repositories(:rhel_7_no_arch)
            product_label = repo.product.label
            metadata = {
              products: {
                product_label => { label: product_label }
              },
              repositories: {
                "misc-24037": { "label": repo.label + "foo",
                                "product": { label: product_label },
                                "content": repo.content.slice(:id, :label),
                                "redhat": repo.redhat?,
                                "arch": repo.arch,
                                "minor": repo.minor
                              }
              },
              gpg_keys: {}
            }.with_indifferent_access
            helper = Katello::Pulp3::ContentViewVersion::ImportableRepositories.
                      new(organization: repo.organization, metadata: metadata, redhat: true)
            helper.generate!

            assert_includes helper.creatable.map { |r| r[:product].label }, product_label
            assert_includes helper.creatable.map { |r| r[:content].label }, repo.content.label
            assert_includes helper.creatable.map { |r| r[:substitutions][:basearch] }, repo.arch
            assert_includes helper.creatable.map { |r| r[:substitutions][:releasever] }, repo.minor
          end
        end
      end
    end
  end
end
