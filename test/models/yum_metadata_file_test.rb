require 'katello_test_helper'

module Katello
  class YumMetadataFileTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:fedora_17_x86_64)
      @ymf1 = katello_yum_metadata_files(:one)
      @ymf2 = katello_yum_metadata_files(:two)

      YumMetadataFile.any_instance.stubs(:backend_data).returns({})
    end
  end

  class YumMetadataFileTest < YumMetadataFileTestBase
    def test_create
      uuid = 'foo'
      assert YumMetadataFile.create!(:uuid => uuid)
      assert YumMetadataFile.find_by_uuid(uuid)
    end

    def test_with_identifiers_single
      assert_includes YumMetadataFile.with_identifiers(@ymf1.id), @ymf1
    end

    def test_with_multiple
      ymfs = YumMetadataFile.with_identifiers([@ymf1.id, @ymf2.uuid])

      assert_equal 2, ymfs.count
      assert_include ymfs, @ymf1
      assert_include ymfs, @ymf2
    end

    def test_in_repositories_uniqness
      repo2 = katello_repositories(:rhel_7_x86_64)
      @repo.yum_metadata_files = [@ymf1, @ymf2]
      repo2.yum_metadata_files = [@ymf1, @ymf2]

      assert_equal YumMetadataFile.in_repositories([@repo, repo2]), [@ymf1, @ymf2]
    end

    def test_update_from_json
      uuid = 'foo'
      name = "foo.gz"
      YumMetadataFile.create!(:uuid => uuid)
      json = @ymf1.attributes.merge('checksum' => 'xxxxxx',
                                    '_storage_path' => "/var/lib/pulp/foo/#{name}")
      @ymf1.update_from_json(json.with_indifferent_access)
      @ymf1 = @ymf1.reload
      refute @ymf1.checksum.blank?
      assert_equal name, @ymf1.name
    end

    def test_with_identifiers
      assert_includes YumMetadataFile.with_identifiers(@ymf1.id), @ymf1
      assert_includes YumMetadataFile.with_identifiers([@ymf1.id]), @ymf1
      assert_includes YumMetadataFile.with_identifiers(@ymf1.uuid), @ymf1
    end

    def test_copy_repository_associations
      repo_one = @repo
      repo_two = katello_repositories(:fedora_17_x86_64_dev)

      repo_one.yum_metadata_files = [@ymf1]
      repo_two.yum_metadata_files = [@ymf2]

      Katello::YumMetadataFile.copy_repository_associations(repo_one, repo_two)
      assert_equal [@ymf1.checksum], repo_two.reload.yum_metadata_files.map(&:checksum)
    end
  end
end
