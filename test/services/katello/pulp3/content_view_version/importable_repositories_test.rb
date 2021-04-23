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
            gpg_key = "MyCoolKey10000"
            metadata = {
              repository_mapping: {
                "misc-24037": { "label": repo.label,
                                "product": { label: repo.product.label },
                                "redhat": repo.redhat?
                              },
                "hoo-24037": { "label": new_repo_1,
                               "product": { label: repo.product.label },
                               "redhat": false
                              },
                "hah-24037": { "label": new_repo_2,
                               "product": { label: repo.product.label },
                               "redhat": false,
                               "gpg_key": { name: gpg_key, content: "wow" }
                              }
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

            refute_nil repo.organization.gpg_keys.find_by(name: gpg_key)
          end
        end
      end
    end
  end
end
