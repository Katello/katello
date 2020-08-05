require 'katello_test_helper'

module ::Actions::Pulp3
  class CopyAllUnitsFileRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @file_repo = katello_repositories(:generic_file)
      @file_clone = katello_repositories(:generic_file_dev)
    end

    def test_file_repo_copy_all_units_uses_same_version_href
      @file_repo.update!(:version_href => "my/custom/path")
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits, @file_clone, @master, [@file_repo])
      refute_nil(@file_repo.version_href)
      refute_nil(@file_clone.version_href)
      assert_equal @file_repo.version_href, @file_clone.version_href
    end
  end

  class CopyAllUnitsDockerRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @docker_repo = katello_repositories(:busybox)
      @docker_repo.root.update!(docker_tags_whitelist: %w(latest uclibc musl))
      @docker_clone = katello_repositories(:busybox_dev)
      @rule = FactoryBot.build(:katello_content_view_docker_filter_rule)
      @rule2 = FactoryBot.build(:katello_content_view_docker_filter_rule)

      ensure_creatable(@docker_repo, @master)
      create_repo(@docker_repo, @master)
      ensure_creatable(@docker_clone, @master)
      create_repo(@docker_clone, @master)
    end

    def test_inclusion_docker_filters
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

      @file_clone = katello_repositories(:generic_file_dev)
      @docker_clone = katello_repositories(:busybox_dev)
      @rule = FactoryBot.build(:katello_content_view_docker_filter_rule)
      @rule2 = FactoryBot.build(:katello_content_view_docker_filter_rule)
    end

    def test_exclusion_docker_filters
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

  class CopyAllUnitYumRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')

      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ensure_creatable(@repo_clone, @master)
      create_repo(@repo_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)

      index_args = {:id => @repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def test_yum_copy_all_no_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter)
      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal @repo.rpms, @repo_clone.rpms
      refute_nil(@repo.version_href)
      refute_nil(@repo_clone.version_href)
      assert_not_equal @repo.version_href, @repo_clone.version_href
      assert_not_equal @repo_clone.version_href, @repo_clone_original_version_href
    end

    def test_yum_copy_with_errata_exclusion_filter
      filter = FactoryBot.create(:katello_content_view_erratum_filter, :inclusion => false)
      FactoryBot.create(:katello_content_view_erratum_filter_rule, :filter => filter, :errata_id => "RHEA-2012:0056")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], solve_dependencies: false, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_includes @repo_clone.rpms.pluck(:name), "crow"
      refute_includes @repo_clone.rpms.pluck(:name), "duck"
      refute_includes @repo_clone.rpms.pluck(:name), "stork"
      refute_includes @repo_clone.errata.pluck(:pulp_id), "RHEA-2012:0056"
    end

    def test_yum_copy_with_errata_inclusion_filter
      filter = FactoryBot.create(:katello_content_view_erratum_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_erratum_filter_rule, :filter => filter, :errata_id => "RHEA-2012:0056")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], solve_dependencies: false, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      assert_equal ['crow', 'duck', 'stork'].sort, @repo_clone.rpms.pluck(:name).sort
      assert_equal ["RHEA-2012:0056"], @repo_clone.errata.pluck(:pulp_id)
    end

    def test_yum_copy_all_no_filter_rules_without_dependency_solving
      filter = FactoryBot.create(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "trout")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], solve_dependencies: false, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal ["trout-0.12-1.noarch.rpm"], @repo_clone.rpms.pluck(:filename)
    end

    def test_yum_copy_nonmatching_package_includion_filter_copies_no_content
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "firefox")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], solve_dependencies: true, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_empty @repo_clone.rpms
    end

    def test_yum_copy_nonmatching_package_exclusion_filter_copies_everything
      filter = FactoryBot.build(:katello_content_view_package_filter)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "firefox")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], solve_dependencies: true, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal 32, @repo_clone.rpms.pluck(:name).sort.count
    end

    def test_yum_copy_all_no_filter_rules_with_dependency_solving
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "trout")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], solve_dependencies: true, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal ["bear", "cat", "crow", "dolphin", "elephant", "gorilla", "horse",
                    "kangaroo", "lion", "mouse", "penguin", "pike", "tiger", "trout",
                    "wolf", "zebra"], @repo_clone.rpms.pluck(:name).sort
    end

    def test_yum_copy_with_whitelist_name_filter
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "kangaroo")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal ['kangaroo'], @repo_clone.rpms.pluck(:name)
    end

    def test_yum_copy_with_whitelist_min_version_filter
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "walrus", :min_version => "4")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal ['walrus-5.21-1.noarch.rpm'], @repo_clone.rpms.pluck(:filename)
    end

    def test_yum_copy_with_whitelist_max_version_filter
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "walrus", :max_version => "4")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal ['walrus-0.71-1.noarch.rpm'], @repo_clone.rpms.pluck(:filename)
    end

    def test_yum_copy_with_duplicate_content
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      assert_equal 32, @repo.rpms.count
      assert_includes @repo.rpms.pluck(:filename), 'walrus-0.71-1.noarch.rpm'

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])

      @repo_clone.reload
      refute_equal @repo_clone.version_href, @repo_clone_original_version_href

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)

      @repo_clone.reload

      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "walrus", :max_version => "4")
      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload

      refute_equal @repo_clone.version_href, @repo_clone_original_version_href

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      assert_equal ['walrus-0.71-1.noarch.rpm'], @repo_clone.rpms.pluck(:filename)
    end

    def test_yum_copy_with_all_duplicate_content_with_dep_solving
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "walrus", :max_version => "4")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], solve_dependencies: true, filters: [filter])

      @repo_clone.reload
      refute_equal @repo_clone.version_href, @repo_clone_original_version_href

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)

      @repo_clone.reload

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], solve_dependencies: true, filters: [filter])
      @repo_clone.reload
      assert_equal @repo_clone.version_href, @repo_clone_original_version_href

      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      assert_equal ["whale-0.2-1.noarch.rpm", "walrus-0.71-1.noarch.rpm", "stork-0.12-2.noarch.rpm", "shark-0.1-1.noarch.rpm"].sort,
        @repo_clone.rpms.pluck(:filename).sort
    end
  end

  class CopyAllUnitYumSrpmsRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'https://fixtures.pulpproject.org/srpm-unsigned/')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'https://fixtures.pulpproject.org/srpm-unsigned/')

      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ensure_creatable(@repo_clone, @master)
      create_repo(@repo_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)

      index_args = {:id => @repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def test_all_srpms_copied_despite_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "kangaroo")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.srpms
      assert_equal @repo_clone.srpms, @repo.srpms
    end
  end

  class CopyAllUnitYumErrataRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ensure_creatable(@repo_clone, @master)
      create_repo(@repo_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)

      index_args = {:id => @repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def test_all_errata_copied_if_no_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexErrata, @repo_clone)
      @repo_clone.reload

      refute_empty @repo.errata
      assert_equal ["KATELLO-RHEA-2010:0002", "KATELLO-RHEA-2010:0111", "KATELLO-RHEA-2010:99143", "KATELLO-RHEA-2012:0059"].sort, @repo_clone.errata.pluck(:errata_id).sort
    end

    def test_no_errata_copied_if_no_errata_packages_matches_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "cheetah")
      module_stream_filter = FactoryBot.create(:katello_content_view_module_stream_filter, :inclusion => true)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter, module_stream_filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.errata
      assert_empty @repo_clone.errata
    end

    def test_errata_copied_if_all_errata_packages_matches_included_packages
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'lion')
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'elephant')

      module_stream_filter = FactoryBot.create(:katello_content_view_module_stream_filter, :inclusion => true)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter, module_stream_filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.errata
      assert_equal ["KATELLO-RHEA-2010:0002", "KATELLO-RHEA-2010:0111"].sort, @repo_clone.errata.pluck(:errata_id).sort
    end

    def test_errata_is_not_copied_if_errata_packages_are_not_all_found_in_included_packages
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'shark')
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'walrus')

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.errata
      assert_empty [], @repo_clone.errata
    end
  end

  class CopyAllUnitYumModuleStreamRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ensure_creatable(@repo_clone, @master)
      create_repo(@repo_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)

      index_args = {:id => @repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def test_all_module_streams_copied_if_no_modular_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, @repo_clone)
      @repo_clone.reload
      refute_empty @repo.module_streams
      assert_equal @repo.module_streams.pluck(:name).sort, @repo_clone.module_streams.pluck(:name).sort
    end

    def test_all_module_streams_copied_if_empty_modular_filter_rules
      filter = FactoryBot.build(:katello_content_view_module_stream_filter, :inclusion => true)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, @repo_clone)
      @repo_clone.reload

      refute_empty @repo.module_streams
      assert_equal @repo.module_streams.pluck(:id).sort, @repo_clone.module_streams.pluck(:id).sort
    end

    def test_module_streams_copied_with_include_modular_filter_rules
      filter = FactoryBot.build(:katello_content_view_module_stream_filter, :inclusion => true)
      duck = @repo.module_streams.where(:name => "duck").first
      FactoryBot.create(:katello_content_view_module_stream_filter_rule,
                                   :filter => filter,
                                   :module_stream => duck)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, @repo_clone)
      @repo_clone.reload

      refute_empty @repo.module_streams
      assert_equal @repo_clone.module_streams.size, 1
      assert_equal duck.name, @repo_clone.module_streams.first.name
    end

    def test_module_streams_copied_with_modular_exclude_filter_rules
      filter = FactoryBot.build(:katello_content_view_module_stream_filter, :inclusion => false)
      duck = @repo.module_streams.where(:name => "duck").first
      FactoryBot.create(:katello_content_view_module_stream_filter_rule,
                                    :filter => filter,
                                    :module_stream => duck)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, @repo_clone)
      @repo_clone.reload

      refute_empty @repo.module_streams
      assert_equal @repo_clone.module_streams.size, 5
      refute_includes @repo_clone.module_streams.pluck(:pulp_id), duck.pulp_id
    end
  end

  class CopyAllUnitYumPackageGroupsRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ensure_creatable(@repo_clone, @master)
      create_repo(@repo_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)

      index_args = {:id => @repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def test_all_package_groups_copied_with_no_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexPackageGroups, @repo_clone)
      @repo_clone.reload

      refute_empty @repo.package_groups
      assert_equal @repo_clone.package_groups, @repo.package_groups
    end

    def test_package_groups_as_a_filter_rule
      filter = FactoryBot.create(:katello_content_view_package_group_filter, :inclusion => true)
      birds = @repo.package_groups.where(:name => "bird").first
      FactoryBot.create(:katello_content_view_package_group_filter_rule, :filter => filter, :uuid => birds.pulp_id)

      module_stream_filter = FactoryBot.create(:katello_content_view_module_stream_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter, module_stream_filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.package_groups
      assert_equal ['bird'], @repo_clone.package_groups.pluck(:name)
      assert_equal ['penguin', 'duck'].sort, @repo_clone.rpms.pluck(:name).uniq.sort
    end

    def test_package_groups_copied_if_indicated_by_copied_packages
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'cheetah')

      module_stream_filter = FactoryBot.create(:katello_content_view_module_stream_filter, :inclusion => true)
      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter, module_stream_filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexPackageGroups, @repo_clone)
      @repo_clone.reload

      refute_empty @repo.package_groups
      assert_equal ["mammal"], @repo_clone.package_groups.pluck(:name)
    end
  end

  class CopyAllUnitYumPackageEnvironmentRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ensure_creatable(@repo_clone, @master)
      create_repo(@repo_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)

      index_args = {:id => @repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def test_all_package_environments_are_copied_by_default
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_packageenvironment_response = @repo.backend_service(@master).api.content_package_environments_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_packageenvironment_response = @repo_clone.backend_service(@master).api.content_package_environments_api.list(options)

      refute_empty repo_packageenvironment_response.results
      assert_equal repo_packageenvironment_response.results, repo_clone_packageenvironment_response.results
    end

    def test_all_package_environments_are_copied_even_if_no_groups_match
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "trout")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_packageenvironment_response = @repo.backend_service(@master).api.content_package_environments_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_packageenvironment_response = @repo_clone.backend_service(@master).api.content_package_environments_api.list(options)

      refute_empty repo_packageenvironment_response.results
      assert_equal repo_packageenvironment_response.results, repo_clone_packageenvironment_response.results
    end
  end

  class CopyAllUnitYumDistributionTreesRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @master)
      create_repo(@repo, @master)
      ensure_creatable(@repo_clone, @master)
      create_repo(@repo_clone, @master)

      sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)

      index_args = {:id => @repo.id, :contents_changed => true}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def test_all_distribution_trees_are_copied_by_default
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_distribution_trees_response = @repo.backend_service(@master).api.content_distribution_trees_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_distribution_trees_response = @repo_clone.backend_service(@master).api.content_distribution_trees_api.list(options)

      refute_empty repo_distribution_trees_response.results
      assert_equal repo_distribution_trees_response.results, repo_clone_distribution_trees_response.results
    end

    def test_no_package_environments_are_copied_despite_whitelist_ids
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "trout")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @master, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_distribution_trees_response = @repo.backend_service(@master).api.content_distribution_trees_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_distribution_trees_response = @repo_clone.backend_service(@master).api.content_distribution_trees_api.list(options)

      refute_empty repo_distribution_trees_response.results
      assert_equal repo_distribution_trees_response.results, repo_clone_distribution_trees_response.results
    end
  end
end
