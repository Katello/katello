require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  class ContentViewPackageGroupFilterTest < ActiveSupport::TestCase
    include Pulp3Support
    def setup
      User.current = User.find(users(:admin).id)
    end

    def teardown
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
      @repo.reload
    end

    def test_content_unit_pulp_ids_returns_pulp_hrefs
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64)
      @repo.root.update!(:url => 'https://repos.fedorapeople.org/repos/pulp/pulp/fixtures/rpm-unsigned/')
      @repo.root.update!(:download_policy => 'immediate')
      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ForemanTasks.sync_task(
          ::Actions::Katello::Repository::MetadataGenerate, @repo,
          repository_creation: true)
      @repo.reload
      sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
      @repo.reload
      @repo.index_content
      Katello::PackageGroup.import_for_repository(@repo)
      @repo.reload

      birds = @repo.package_groups.where(:name => "birds").first

      first_rule = FactoryBot.create(:katello_content_view_package_group_filter_rule, :uuid => birds.pulp_id)

      bird_pulp_ids = @repo.rpms.where(:name => ["cockateel", "duck", "penguin", "stork"]).pluck(:pulp_id)

      assert_equal bird_pulp_ids, first_rule.filter.content_unit_pulp_ids(@repo)
    end
  end
end
