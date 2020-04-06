require 'katello_test_helper'

module ::Actions::Pulp3
  class CopyAllUnitsTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @file_repo = katello_repositories(:generic_file)
      @docker_repo = katello_repositories(:busybox)
      @docker_repo.root.update!(docker_tags_whitelist: %w(latest uclibc musl))

      @file_clone = katello_repositories(:generic_file_dev)
      @docker_clone = katello_repositories(:busybox_dev)
      @rule = FactoryBot.build(:katello_content_view_docker_filter_rule)
      @rule2 = FactoryBot.build(:katello_content_view_docker_filter_rule)
    end

    def test_create
      @file_repo.update!(:version_href => "my/custom/path")
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits, @file_clone, @master, [@file_repo])
      refute_nil(@file_repo.version_href)
      refute_nil(@file_clone.version_href)
      assert_equal @file_repo.version_href, @file_clone.version_href
    end

    def test_inclusion_docker_filters
      ensure_creatable(@docker_repo, @master)
      create_repo(@docker_repo, @master)
      ensure_creatable(@docker_clone, @master)
      create_repo(@docker_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @docker_repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @docker_repo, @master, sync_args)
      index_args = {:id => @docker_repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @docker_repo.reload

      @rule.name = "latest"
      @rule2.name = "uclibc"
      @rule.save!
      @rule2.save!
      filter = FactoryBot.build(:katello_content_view_docker_filter, :docker_rules => [@rule, @rule2])
      filter.inclusion = true
      filter.save

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @docker_clone, @master, [@docker_repo], filters: [filter])
      @docker_clone.reload
      @docker_clone.index_content
      ::Katello::DockerMetaTag.import_meta_tags([@docker_clone])

      refute_nil(@docker_repo.version_href)
      refute_nil(@docker_clone.version_href)
      assert_not_equal @docker_repo.version_href, @docker_clone.version_href
      assert_equal @docker_clone.docker_tags.pluck(:name).sort, ["latest", "uclibc"]
    end

    def test_exclusion_docker_filters
      ensure_creatable(@docker_repo, @master)
      create_repo(@docker_repo, @master)
      ensure_creatable(@docker_clone, @master)
      create_repo(@docker_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @docker_repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @docker_repo, @master, sync_args)
      index_args = {:id => @docker_repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @docker_repo.reload

      @rule.name = "latest"
      @rule.save!
      filter = FactoryBot.build(:katello_content_view_docker_filter, :docker_rules => [@rule])
      filter.save

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @docker_clone, @master, [@docker_repo], filters: [filter])
      @docker_clone.reload
      @docker_clone.index_content
      ::Katello::DockerMetaTag.import_meta_tags([@docker_clone])

      refute_nil(@docker_repo.version_href)
      refute_nil(@docker_clone.version_href)
      assert_not_equal @docker_repo.version_href, @docker_clone.version_href
      assert_equal @docker_clone.docker_tags.pluck(:name), @docker_repo.docker_tags.pluck(:name) - ["latest"]
    end
  end
end
