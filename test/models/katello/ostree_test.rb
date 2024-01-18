require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  class OstreeTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      skip "TODO: Until the ostree support is present in pulp packaging"
      # NOTE in order for these tests to work the 'ostree' fixture will have to be enabled in
      # test/fixtures/models/katello_smart_proxy_features.yml
      #   capabilities:
      #     - ostree
      @repo = FactoryBot.build(:katello_repository, :ostree, :with_product)
      @primary = SmartProxy.pulp_primary
      @repo.root.update(url: 'https://fixtures.pulpproject.org/ostree/small/')

      create_repo(@repo, @primary)
      @repo.reload
    end

    def test_created
      skip "TODO: Until the ostree support is present in pulp packaging"
      assert @repo
    end

    def test_index_on_sync
      skip "TODO: Until the ostree support is present in pulp packaging"
      Katello::GenericContentUnit.destroy_all
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
      index_args = {:id => @repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload

      post_unit_count = Katello::GenericContentUnit.all.count
      post_unit_repository_count = Katello::RepositoryGenericContentUnit.where(:repository_id => @repo.id).count

      assert_equal post_unit_count, 2
      assert_equal post_unit_repository_count, 2
    end
  end
end
