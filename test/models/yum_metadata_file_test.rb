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
      pulp_id = 'foo'
      assert YumMetadataFile.create!(:pulp_id => pulp_id)
      assert YumMetadataFile.find_by_pulp_id(pulp_id)
    end

    def test_with_identifiers_single
      assert_includes YumMetadataFile.with_identifiers(@ymf1.id), @ymf1
    end

    def test_with_multiple
      ymfs = YumMetadataFile.with_identifiers([@ymf1.id, @ymf2.pulp_id])

      assert_equal 2, ymfs.count
      assert_include ymfs, @ymf1
      assert_include ymfs, @ymf2
    end

    def test_in_repositories_uniqness
      repo2 = katello_repositories(:rhel_7_x86_64)
      @repo.yum_metadata_files = [@ymf1, @ymf2]
      repo2.yum_metadata_files = [@ymf1, @ymf2]

      assert_equal YumMetadataFile.in_repositories([@repo, repo2]).to_a.sort, [@ymf1, @ymf2].sort
    end

    def test_with_identifiers
      assert_includes YumMetadataFile.with_identifiers(@ymf1.id), @ymf1
      assert_includes YumMetadataFile.with_identifiers([@ymf1.id]), @ymf1
      assert_includes YumMetadataFile.with_identifiers(@ymf1.pulp_id), @ymf1
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
