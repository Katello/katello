require 'katello_test_helper'

module ::Actions::Pulp3
  class CopyAllUnitsFileRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @file_repo = katello_repositories(:generic_file)
      @file_clone = katello_repositories(:generic_file_dev)
    end

    def teardown
      ensure_creatable(@file_repo, @primary)
      ensure_creatable(@file_clone, @primary)
    end

    def test_file_repo_copy_all_units_uses_same_version_href
      @file_repo.update!(:version_href => "my/custom/path")
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits, @file_clone, @primary, [@file_repo])
      refute_nil(@file_repo.version_href)
      refute_nil(@file_clone.version_href)
      assert_equal @file_repo.version_href, @file_clone.version_href
    end
  end

  class CopyAllUnitsDockerRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @docker_repo = katello_repositories(:busybox)
      @docker_repo.root.update!(include_tags: %w(latest glibc musl))
      @docker_clone = katello_repositories(:busybox_dev)
      @rule = FactoryBot.build(:katello_content_view_docker_filter_rule)
      @rule2 = FactoryBot.build(:katello_content_view_docker_filter_rule)

      ensure_creatable(@docker_repo, @primary)
      create_repo(@docker_repo, @primary)
      ensure_creatable(@docker_clone, @primary)
      create_repo(@docker_clone, @primary)
    end

    def teardown
      ensure_creatable(@docker_repo, @primary)
      ensure_creatable(@docker_clone, @primary)
    end

    def test_inclusion_docker_filters
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @docker_repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @docker_repo, @primary, sync_args)
      index_args = {:id => @docker_repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @docker_repo.reload

      @rule.name = "latest"
      @rule2.name = "glibc"
      @rule.save!
      @rule2.save!
      filter = FactoryBot.build(:katello_content_view_docker_filter, :docker_rules => [@rule, @rule2])
      filter.inclusion = true
      filter.save
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @docker_clone, @primary, [@docker_repo], filters: [filter])
      @docker_clone.reload
      @docker_clone.index_content
      ::Katello::DockerMetaTag.import_meta_tags([@docker_clone])

      refute_nil(@docker_repo.version_href)
      refute_nil(@docker_clone.version_href)
      assert_not_equal @docker_repo.version_href, @docker_clone.version_href
      assert_equal @docker_clone.docker_tags.pluck(:name).sort, ["latest", "glibc"].sort
    end

    def test_exclusion_docker_filters
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @docker_repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @docker_repo, @primary, sync_args)
      index_args = {:id => @docker_repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @docker_repo.reload

      @rule.name = "latest"
      @rule.save!
      filter = FactoryBot.build(:katello_content_view_docker_filter, :docker_rules => [@rule])
      filter.save

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @docker_clone, @primary, [@docker_repo], filters: [filter])
      @docker_clone.reload
      @docker_clone.index_content
      ::Katello::DockerMetaTag.import_meta_tags([@docker_clone])

      refute_nil(@docker_repo.version_href)
      refute_nil(@docker_clone.version_href)
      assert_not_equal @docker_repo.version_href, @docker_clone.version_href
      assert_equal @docker_clone.docker_tags.pluck(:name).sort, @docker_repo.docker_tags.pluck(:name).sort - ["latest"]
    end
  end

  class CopyAllUnitYumRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')

      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      create_repo(@repo_clone, @primary)

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def teardown
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
    end

    def test_yum_copy_all_no_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter)
      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
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
                             @repo_clone, @primary, [@repo], solve_dependencies: false, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
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
                             @repo_clone, @primary, [@repo], solve_dependencies: false, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      assert_equal ['crow', 'duck', 'stork'].sort, @repo_clone.rpms.pluck(:name).sort
      assert_equal ["RHEA-2012:0056"], @repo_clone.errata.pluck(:pulp_id)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def test_copy_duplicated_errata
      # https://bugzilla.redhat.com/show_bug.cgi?id=2013320

      repo2 = katello_repositories(:rhel_7_x86_64)
      repo3 = katello_repositories(:rhel_6_x86_64)
      repo2.update!(:environment_id => nil)
      repo3.update!(:environment_id => nil)
      @repo.root.update!(download_policy: 'immediate')
      repo2.root.update!(download_policy: 'immediate')
      repo3.root.update!(download_policy: 'immediate')
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo')
      repo2.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo_dup')
      repo3.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo_dup_dup')

      ::Katello::Pulp3::Repository.any_instance.stubs(:ssl_remote_options).returns({})
      create_repo(repo2, @primary)
      create_repo(repo3, @primary)

      ::Katello::Pulp3::Repository::Yum.any_instance.stubs(:generate_backend_object_name).returns(@repo.pulp_id)
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
      ::Katello::Pulp3::Repository::Yum.any_instance.stubs(:generate_backend_object_name).returns(repo2.pulp_id)
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => repo2.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, repo2, @primary, sync_args)
      ::Katello::Pulp3::Repository::Yum.any_instance.stubs(:generate_backend_object_name).returns(repo3.pulp_id)
      sync_args = {:smart_proxy_id => @primary.id, :repo_id => repo3.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, repo3, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      index_args = {:id => repo2.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      index_args = {:id => repo3.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
      repo2.reload
      repo3.reload

      stub_constant(::Katello::Pulp3::Repository::Yum, :UNIT_LIMIT, 2) do
        filter = FactoryBot.create(:katello_content_view_erratum_filter, :inclusion => true)
        FactoryBot.create(:katello_content_view_erratum_filter_rule, :filter => filter, :errata_id => "KATELLO-RHEA-2010:99143")

        @repo_clone_original_version_href = @repo_clone.version_href
        ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                              @repo_clone, @primary, [@repo], solve_dependencies: false, filters: [filter])
      end
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      assert_equal ['armadillo'], @repo_clone.rpms.pluck(:name)
      assert_equal ["KATELLO-RHEA-2010:0001", "KATELLO-RHEA-2010:99143", "KATELLO-RHSA-2010:0858", "RHEA-2021:9999"].sort, @repo_clone.errata.pluck(:pulp_id).sort
    ensure
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      ensure_creatable(repo2, @primary)
      ensure_creatable(repo3, @primary)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def test_yum_copy_all_no_filter_rules_without_dependency_solving
      filter = FactoryBot.create(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "trout")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], solve_dependencies: false, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
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
                             @repo_clone, @primary, [@repo], solve_dependencies: true, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
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
                             @repo_clone, @primary, [@repo], solve_dependencies: true, filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal 32, @repo_clone.rpms.pluck(:name).sort.count
    end

    def test_yum_copy_with_whitelist_name_filter
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "kangaroo")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      assert_equal ['kangaroo'], @repo_clone.rpms.pluck(:name)
    end

    def test_yum_copy_with_whitelist_name_original_packages_filter
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true, :original_packages => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "kangaroo")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.rpms
      expected_rpms = ["zebra", "walrus", "whale", "tiger", "squirrel", "wolf", "pike", "horse", "lion", "kangaroo", "cow",
                       "dolphin", "cockateel", "cheetah", "mouse", "giraffe", "frog", "chimpanzee", "elephant", "fox", "cat", "dog", "camel", "trout"].sort
      assert_equal expected_rpms, @repo_clone.rpms.pluck(:name).sort
    end

    def test_yum_copy_with_whitelist_min_version_filter
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "walrus", :min_version => "4")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
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
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload

      index_args = {:id => @repo_clone.id}
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
                             @repo_clone, @primary, [@repo], filters: [filter])

      @repo_clone.reload
      refute_equal @repo_clone.version_href, @repo_clone_original_version_href

      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)

      @repo_clone.reload

      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "walrus", :max_version => "4")
      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload

      refute_equal @repo_clone.version_href, @repo_clone_original_version_href

      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      assert_equal ['walrus-0.71-1.noarch.rpm'], @repo_clone.rpms.pluck(:filename)
    end
  end

  class CopyAllUnitYumSrpmsRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'https://fixtures.pulpproject.org/srpm-unsigned/')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'https://fixtures.pulpproject.org/srpm-unsigned/')

      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      create_repo(@repo_clone, @primary)

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def teardown
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
    end

    def test_all_srpms_copied_despite_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "kangaroo")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.srpms
      assert_equal @repo_clone.srpms, @repo.srpms
    end
  end

  class CopyAllUnitYumErrataRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      create_repo(@repo_clone, @primary)

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def teardown
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
    end

    def test_all_errata_copied_if_no_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexErrata, @repo_clone)
      @repo_clone.reload

      refute_empty @repo.errata
      assert_equal ["KATELLO-RHEA-2010:0001", "KATELLO-RHEA-2010:0002", "KATELLO-RHEA-2010:0111", "KATELLO-RHEA-2010:99143", "KATELLO-RHEA-2012:0059", "KATELLO-RHSA-2010:0858", "RHEA-2021:9999"].sort,
        @repo_clone.errata.pluck(:errata_id).sort
    end

    # Proper errata here are SRPM errata, empty errata, and errata that share no RPMs with the source repository.
    def test_proper_errata_copied_if_no_errata_packages_matches_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "cheetah")
      module_stream_filter = FactoryBot.create(:katello_content_view_module_stream_filter, :inclusion => true)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter, module_stream_filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.errata
      assert_equal ::Katello::Erratum.where(errata_id: ["RHEA-2021:9999", "KATELLO-RHEA-2010:0001", "KATELLO-RHSA-2010:0858"]).sort, @repo_clone.errata.sort
    end

    def test_errata_copied_if_all_errata_packages_matches_included_packages
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'lion')
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'elephant')

      module_stream_filter = FactoryBot.create(:katello_content_view_module_stream_filter, :inclusion => true)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter, module_stream_filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.errata
      assert_equal ["KATELLO-RHEA-2010:0001", "KATELLO-RHEA-2010:0002", "KATELLO-RHEA-2010:0111", "KATELLO-RHSA-2010:0858", "RHEA-2021:9999"].sort, @repo_clone.errata.pluck(:errata_id).sort
    end

    def test_errata_is_not_copied_if_errata_packages_are_not_all_found_in_included_packages
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'shark')
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => 'walrus')

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.errata
      assert_empty [], @repo_clone.errata
    end
  end

  class CopyAllUnitYumModuleStreamRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      create_repo(@repo_clone, @primary)

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def teardown
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
    end

    def test_all_module_streams_copied_if_no_modular_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, @repo_clone)
      @repo_clone.reload
      refute_empty @repo.module_streams
      assert_equal @repo.module_streams.pluck(:name).sort, @repo_clone.module_streams.pluck(:name).sort
    end

    def test_all_module_streams_copied_if_empty_modular_filter_rules
      filter = FactoryBot.build(:katello_content_view_module_stream_filter, :inclusion => true)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, @repo_clone)
      @repo_clone.reload

      refute_empty @repo.module_streams
      assert_equal @repo.module_streams.pluck(:id).sort, @repo_clone.module_streams.pluck(:id).sort
    end

    def test_module_streams_copied_from_actual_source_repo
      # Try to copy a module stream from a source repository that doesn't have it.
      filter = FactoryBot.build(:katello_content_view_module_stream_filter, :inclusion => true)
      duck = @repo.module_streams.where(:name => "duck").first
      FactoryBot.create(:katello_content_view_module_stream_filter_rule,
                                   :filter => filter,
                                   :module_stream => duck)
      @repo.root.update!(:url => 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])

      @repo_clone.reload.index_content
      assert_empty @repo_clone.reload.module_streams
    end

    def test_module_streams_copied_with_include_modular_filter_rules
      filter = FactoryBot.build(:katello_content_view_module_stream_filter, :inclusion => true)
      duck = @repo.module_streams.where(:name => "duck").first
      FactoryBot.create(:katello_content_view_module_stream_filter_rule,
                                   :filter => filter,
                                   :module_stream => duck)

      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
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
                             @repo_clone, @primary, [@repo], filters: [filter])
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
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      create_repo(@repo_clone, @primary)

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def teardown
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
    end

    def test_all_package_groups_copied_with_no_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])
      @repo_clone.reload
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexPackageGroups, @repo_clone)
      @repo_clone.reload

      assert_equal ['bird', 'mammal'], @repo_clone.package_groups.pluck(:name).sort
    end

    def test_package_groups_as_a_filter_rule
      filter = FactoryBot.create(:katello_content_view_package_group_filter, :inclusion => true)
      birds = @repo.package_groups.where(:name => "bird").first
      FactoryBot.create(:katello_content_view_package_group_filter_rule, :filter => filter, :uuid => birds.pulp_id)

      module_stream_filter = FactoryBot.create(:katello_content_view_module_stream_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter, module_stream_filter])
      @repo_clone.reload
      index_args = {:id => @repo_clone.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo_clone.reload

      refute_empty @repo.package_groups
      assert_equal ['bird'], @repo_clone.package_groups.pluck(:name)
      assert_equal ['penguin', 'duck'].sort, @repo_clone.rpms.pluck(:name).uniq.sort
    end
  end

  class CopyAllUnitYumPackageEnvironmentRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      create_repo(@repo_clone, @primary)

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def teardown
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
    end

    def test_all_package_environments_are_copied_by_default
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_packageenvironment_response = @repo.backend_service(@primary).api.content_package_environments_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_packageenvironment_response = @repo_clone.backend_service(@primary).api.content_package_environments_api.list(options)

      refute_empty repo_packageenvironment_response.results
      assert_equal repo_packageenvironment_response.results, repo_clone_packageenvironment_response.results
    end

    def test_all_package_environments_are_copied_even_if_no_groups_match
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "trout")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_packageenvironment_response = @repo.backend_service(@primary).api.content_package_environments_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_packageenvironment_response = @repo_clone.backend_service(@primary).api.content_package_environments_api.list(options)

      refute_empty repo_packageenvironment_response.results
      assert_equal repo_packageenvironment_response.results, repo_clone_packageenvironment_response.results
    end
  end

  class CopyAllUnitYumModulemdDefaultsRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      create_repo(@repo_clone, @primary)

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def teardown
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
    end

    def test_all_modulemd_defaults_are_copied_by_default
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_modulemd_defaults_response = @repo.backend_service(@primary).api.content_modulemd_defaults_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_modulemd_defaults_response = @repo_clone.backend_service(@primary).api.content_modulemd_defaults_api.list(options)

      refute_empty repo_modulemd_defaults_response.results
      assert_equal repo_modulemd_defaults_response.results, repo_clone_modulemd_defaults_response.results
    end
  end

  class CopyAllUnitYumDistributionTreesRepositoryTest < ActiveSupport::TestCase
    include Katello::Pulp3Support
    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.update!(:environment_id => nil)
      @repo.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')
      @repo_clone = katello_repositories(:fedora_17_x86_64_dev)
      @repo_clone.update!(:environment_id => nil)
      @repo_clone.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/', :download_policy => 'immediate')

      ensure_creatable(@repo, @primary)
      create_repo(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
      create_repo(@repo_clone, @primary)

      sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)

      index_args = {:id => @repo.id}
      ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
      @repo.reload
    end

    def teardown
      ensure_creatable(@repo, @primary)
      ensure_creatable(@repo_clone, @primary)
    end

    def test_all_distribution_trees_are_copied_by_default
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_distribution_trees_response = @repo.backend_service(@primary).api.content_distribution_trees_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_distribution_trees_response = @repo_clone.backend_service(@primary).api.content_distribution_trees_api.list(options)

      refute_empty repo_distribution_trees_response.results
      assert_equal repo_distribution_trees_response.results, repo_clone_distribution_trees_response.results
    end

    def test_no_package_environments_are_copied_despite_whitelist_ids
      filter = FactoryBot.build(:katello_content_view_package_filter, :inclusion => true)
      FactoryBot.create(:katello_content_view_package_filter_rule, :filter => filter, :name => "trout")

      @repo_clone_original_version_href = @repo_clone.version_href
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                             @repo_clone, @primary, [@repo], filters: [filter])

      @repo_clone.reload

      options = { :repository_version => @repo.version_href }
      repo_distribution_trees_response = @repo.backend_service(@primary).api.content_distribution_trees_api.list(options)

      options = { :repository_version => @repo_clone.version_href }
      repo_clone_distribution_trees_response = @repo_clone.backend_service(@primary).api.content_distribution_trees_api.list(options)

      refute_empty repo_distribution_trees_response.results
      assert_equal repo_distribution_trees_response.results, repo_clone_distribution_trees_response.results
    end
  end
end
