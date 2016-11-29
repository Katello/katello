require 'katello_test_helper'

module Katello
  class OstreeBranchTest < ActiveSupport::TestCase
    REPO_ID = "Default_Organization-Test-ostree".freeze
    BRANCHES = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "ostree_branch.yml")

    def setup
      @branches = YAML.load_file(BRANCHES).values.map(&:deep_symbolize_keys)
      @repo = Repository.find(katello_repositories(:ostree_rhel7).id)

      ids = @branches.map { |attrs| attrs[:_id] }
      ::Katello::Pulp::OstreeBranch.stubs(:ids_for_repository).returns(ids)
      ::Katello::Pulp::OstreeBranch.stubs(:fetch).returns(@branches)
    end

    def test_index_db_ostree_branches
      @repo.index_content
      assert_equal 1, OstreeBranch.count
      assert_equal 1, @repo.ostree_branches.count
      branch_names = @branches.map { |b| b[:branch] }
      assert_equal branch_names.sort, OstreeBranch.all.map(&:name).sort
    end
  end
end
