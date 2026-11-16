require 'katello_test_helper'

module Katello
  class ContentIndexTest < ActiveSupport::TestCase
    def setup
      @index = ContentIndex.create!(:version_href => '/pulp/api/v3/repositories/rpm/rpm/indexed/versions/1/')
      @repo = katello_repositories(:fedora_17_x86_64)
      @other_repo = katello_repositories(:fedora_17_x86_64_dev)
    end

    def test_for_version_returns_the_same_index
      assert_equal @index, ContentIndex.for_version(@index.version_href)
    end

    def test_for_version_creates_the_index_once
      href = '/pulp/api/v3/repositories/rpm/rpm/unindexed/versions/3/'

      assert_difference('ContentIndex.count', 1) do
        assert_equal href, ContentIndex.for_version(href).version_href
        ContentIndex.for_version(href)
      end
    end

    def test_private_to_a_repository_until_another_repository_uses_it
      assert @index.private_to?(@repo)

      @repo.update!(:content_index_id => @index.id)
      assert @index.private_to?(@repo)

      @other_repo.update!(:content_index_id => @index.id)
      refute @index.private_to?(@repo)
    end

    def test_orphaned_ignores_null_pointers
      unused = ContentIndex.create!(:version_href => '/pulp/api/v3/repositories/rpm/rpm/orphan/versions/1/')
      @repo.update!(:content_index_id => @index.id)
      # @other_repo deliberately keeps a NULL content_index_id.

      assert_includes ContentIndex.orphaned, unused
      refute_includes ContentIndex.orphaned, @index
    end

    def test_scope_for_repositories_separates_indexed_from_unindexed
      @repo.update!(:version_href => @index.version_href, :content_index_id => @index.id)

      index_ids, repository_ids = ContentIndex.scope_for_repositories([@repo, @other_repo])

      assert_equal [@index.id], index_ids
      assert_equal [@other_repo.id], repository_ids
    end

    def test_scope_for_repositories_treats_a_pointer_for_another_version_as_absent
      @repo.update!(:version_href => '/pulp/api/v3/repositories/rpm/rpm/moved/versions/2/',
                    :content_index_id => @index.id)

      index_ids, repository_ids = ContentIndex.scope_for_repositories([@repo])

      assert_empty index_ids
      assert_equal [@repo.id], repository_ids
    end
  end
end
