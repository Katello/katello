require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportableRepositoriesTest < ActiveSupport::TestCase
          it "Fetches the right custom repos to create and update" do
            repo = katello_repositories(:fedora_17_x86_64)
            new_repo_1 = "New-Repo-1"
            gpg_key = katello_gpg_keys(:fedora_gpg_key)
            product_label = repo.product.label

            metadata_product = stub(label: product_label)
            metadata_gpg_key = stub(name: gpg_key.name)
            metadata_repositories = [
              stub('updatable repo',
                redhat: repo.redhat?,
                product: metadata_product,
                gpg_key: nil,
                name: repo.name,
                label: repo.label,
                description: repo.description,
                arch: repo.arch,
                unprotected: repo.unprotected,
                content_type: repo.content_type,
                checksum_type: repo.checksum_type,
                os_versions: repo.os_versions,
                major: repo.major,
                minor: repo.minor,
                download_policy: repo.download_policy,
                mirroring_policy: repo.mirroring_policy,
                content: nil
              ),
              stub('new repo 1',
                   name: new_repo_1,
                   label: new_repo_1,
                   description: nil,
                   gpg_key: metadata_gpg_key,
                   redhat: false,
                   product: metadata_product,
                   arch: 'x86_64',
                   unprotected: true,
                   content_type: 'yum',
                   checksum_type: 'sha256',
                   os_versions: [],
                   major: '7',
                   minor: '1',
                   download_policy: 'immediate',
                   mirroring_policy: nil,
                   content: nil
                  )
            ]

            helper = Katello::Pulp3::ContentViewVersion::ImportableRepositories.new(
              organization: repo.organization,
              metadata_repositories: metadata_repositories
            )
            helper.generate!

            assert_includes helper.creatable.map { |r| r[:repository].label }, new_repo_1
            refute_includes helper.creatable.map { |r| r[:repository].label }, repo.label
            assert_includes helper.updatable.map { |r| r[:repository].label }, repo.label
            refute_includes helper.updatable.map { |r| r[:repository].label }, new_repo_1

            assert_equal helper.creatable.first[:repository].gpg_key_id, gpg_key.id
            assert_nil helper.updatable.first[:options][:gpg_key_id]
          end

          it "Fetches the redhat repos to enable by label" do
            repo = katello_repositories(:rhel_7_no_arch)
            product_label = repo.product.label
            metadata_product = stub(label: product_label, cp_id: nil)
            metadata_content = stub(label: repo.content.label, id: nil)
            metadata_repositories = [
              stub(
                name: repo.name,
                label: repo.label + "foo",
                redhat: repo.redhat?,
                product: metadata_product,
                content: metadata_content,
                description: repo.description,
                arch: repo.arch,
                major: repo.major,
                minor: repo.minor
              )
            ]

            helper = Katello::Pulp3::ContentViewVersion::ImportableRepositories.new(
              organization: repo.organization,
              metadata_repositories: metadata_repositories
            )
            helper.generate!

            assert helper.creatable.size, 1
            assert_includes helper.creatable.map { |r| r[:product].label }, product_label
            assert_includes helper.creatable.map { |r| r[:content].label }, repo.content.label
            assert_includes helper.creatable.map { |r| r[:substitutions][:basearch] }, repo.arch
            assert_includes helper.creatable.map { |r| r[:substitutions][:releasever] }, repo.minor
          end

          it "Fetches the redhat repos to enable by cp_id" do
            repo = katello_repositories(:rhel_7_no_arch)
            metadata_product = stub(cp_id: repo.product.cp_id)
            metadata_content = stub(label: repo.content.label, id: repo.content.cp_content_id)
            ::Katello::Product.any_instance.expects(:root_repositories).returns([])
            metadata_repositories = [
              stub(
                name: repo.name,
                label: repo.label + "foo",
                redhat: true,
                product: metadata_product,
                content: metadata_content,
                description: repo.description,
                arch: repo.arch,
                major: repo.major,
                minor: repo.minor
              )
            ]

            helper = Katello::Pulp3::ContentViewVersion::ImportableRepositories.new(
              organization: repo.organization,
              metadata_repositories: metadata_repositories
            )
            helper.generate!

            assert helper.creatable.size, 1
            assert_includes helper.creatable.map { |r| r[:product].label }, repo.product.label
            assert_includes helper.creatable.map { |r| r[:content].label }, repo.content.label
            assert_includes helper.creatable.map { |r| r[:substitutions][:basearch] }, repo.arch
            assert_includes helper.creatable.map { |r| r[:substitutions][:releasever] }, repo.minor
          end
        end
      end
    end
  end
end
