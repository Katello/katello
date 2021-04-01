require 'katello_test_helper'
require 'support/pulp/task_support'
require 'support/pulp/repository_support'

module Katello
  class GluePulpRepoTestBase < ActiveSupport::TestCase
    include VCR::TestCase
    include TaskSupport
    include Dynflow::Testing
    include Support::CapsuleSupport
    include RepositorySupport

    def setup
      set_user
      backend_stubs
      set_ca_file
      @primary_proxy = FactoryBot.create(:smart_proxy, :default_smart_proxy)
      @fedora_17_x86_64_dev = katello_repositories(:fedora_17_x86_64_dev)
      @fedora_17_x86_64 = katello_repositories(:fedora_17_x86_64)
      @fedora_17_library_library_view = katello_repositories(:fedora_17_library_library_view)
      @library_dev_staging_view = katello_content_views(:library_dev_staging_view)
      @fedora_17_x86_64.relative_path = 'test_path/'
      @fedora_17_x86_64.root.url = "file:///var/lib/pulp/sync_imports/test_repos/zoo"
      @fedora_17_x86_64.root.download_policy = 'immediate'
      @fedora_17_x86_64.root.save!
    end

    def backend_stubs
      Product.any_instance.stubs(:certificate).returns(nil)
      Product.any_instance.stubs(:key).returns(nil)
    end
  end

  class GluePulpNonVcrNeedPublishUpdateTests < GluePulpRepoTestBase
    def setup
      super
      @new_task = {'finish_time' => '2017-06-20T13:52:17Z', 'errors' => nil }
      @old_task = {'finish_time' => '2017-06-20T12:52:17Z', 'errors' => nil }
      @new_error_task = {'finish_time' => '2017-06-20T14:52:17Z', 'error' => 'bad_error' }
    end

    def test_index_linked_repo
      archive = @fedora_17_x86_64_dev.archived_instance

      archive.rpms = [katello_rpms(:one)]
      archive.errata = [katello_errata(:security)]
      archive.package_groups = [katello_package_groups(:server_pg)]
      archive.distribution_variant = 'varied variant'
      archive.save
      @fedora_17_x86_64_dev.index_linked_repo

      assert_equal archive.rpms, @fedora_17_x86_64_dev.rpms
      assert_equal archive.errata, @fedora_17_x86_64_dev.errata
      assert_equal archive.package_groups, @fedora_17_x86_64_dev.package_groups
      assert_equal archive.distribution_variant, @fedora_17_x86_64_dev.distribution_variant
    end

    def test_needs_metadata_publish_true
      @fedora_17_x86_64.stubs(:last_publish_task).returns(@old_task)
      @fedora_17_x86_64.stubs(:last_sync_task).returns(@new_task)
      assert @fedora_17_x86_64.needs_metadata_publish?
    end

    def test_needs_metadata_publish_missing_publish
      @fedora_17_x86_64.stubs(:last_publish_task).returns(nil)
      @fedora_17_x86_64.stubs(:last_sync_task).returns(@new_task)
      assert @fedora_17_x86_64.needs_metadata_publish?
    end

    def test_needs_metadata_publish_missing_sync
      @fedora_17_x86_64.stubs(:last_publish_task).returns(@old_task)
      @fedora_17_x86_64.stubs(:last_sync_task).returns(nil)
      refute @fedora_17_x86_64.needs_metadata_publish?
    end

    def test_needs_metadata_publish_false
      @fedora_17_x86_64.stubs(:last_publish_task).returns(@new_task)
      @fedora_17_x86_64.stubs(:last_sync_task).returns(@old_task)
      refute @fedora_17_x86_64.needs_metadata_publish?
    end

    def test_most_recent_task
      assert_nil @fedora_17_x86_64.most_recent_task([])
      assert_equal @new_task, @fedora_17_x86_64.most_recent_task([@old_task, @new_task])
      assert_equal @new_task, @fedora_17_x86_64.most_recent_task([@new_task, @old_task])
      assert_equal @new_error_task, @fedora_17_x86_64.most_recent_task([@new_error_task])
      assert_nil @fedora_17_x86_64.most_recent_task([@new_error_task], true)
      assert_equal @new_task, @fedora_17_x86_64.most_recent_task([@new_error_task, @new_task], true)
    end
  end

  class GluePulpNonVcrTests < GluePulpRepoTestBase
    SHA1 = "sha1".freeze
    SHA256 = "sha256".freeze

    def test_default_url_scheme_is_https
      assert @fedora_17_x86_64.full_path(@pulp_primary).starts_with?('https')
    end

    def test_url_scheme_is_http_when_forced
      assert @fedora_17_x86_64.full_path(@pulp_primary, true).starts_with?('http')
    end

    def test_distributors_match_yum
      yum_config = {
        'relative_url' => '/foo/bar',
        'checksum_type' => nil,
        'http' => true,
        'https' => true
      }
      @fedora_17_x86_64.expects(:generate_distributors).with(capsule_content.smart_proxy).at_least_once.returns(
          [Runcible::Models::YumDistributor.new('/foo/bar', true, true, yum_config)])

      assert @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::YumDistributor.type_id,
                                                     'config' => yum_config}], capsule_content.smart_proxy)
      refute @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::YumCloneDistributor.type_id,
                                                     'config' => yum_config}], capsule_content.smart_proxy)
      refute @fedora_17_x86_64.distributors_match?([], capsule_content.smart_proxy)

      non_nil_checksum = yum_config.clone
      non_nil_checksum['checksum_type'] = 'sha256'
      assert @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::YumDistributor.type_id,
                                                     'config' => non_nil_checksum}], capsule_content.smart_proxy)

      yum_config['relative_url'] = '/arrow/to/the/knee'
      refute @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::YumCloneDistributor.type_id,
                                                     'config' => yum_config}], capsule_content.smart_proxy)
    end

    def test_distributors_match_docker
      docker_config = {
        'protected' => true
      }

      @fedora_17_x86_64.expects(:generate_distributors).with(capsule_content.smart_proxy).at_least_once.returns(
          [Runcible::Models::DockerDistributor.new(docker_config)])

      assert @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::DockerDistributor.type_id,
                                                     'config' => docker_config}], capsule_content.smart_proxy)
      docker_config['protected'] = false
      refute @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::DockerDistributor.type_id,
                                                     'config' => docker_config}], capsule_content.smart_proxy)
    end

    def test_importer_upstream_username_passwd
      repo = katello_repositories(:fedora_17_x86_64)
      username = "justin"
      password = "super-secret"
      repo.root.update!(:upstream_username => username, :upstream_password => password)
      importer = repo.generate_importer
      assert_equal username,  importer.basic_auth_username
      assert_equal password,  importer.basic_auth_password
    end

    def test_importer_upstream_username_passwd_with_capsule
      ::Cert::Certs.stubs(:ueber_cert).returns(:cert => 'foo', :key => 'bar')
      proxy = FactoryBot.build(:smart_proxy, :pulp_mirror)
      repo = katello_repositories(:fedora_17_x86_64)
      username = "justin"
      password = "super-secret"
      repo.root.update!(:upstream_username => username, :upstream_password => password)
      importer = repo.generate_importer(proxy)
      assert_nil importer.basic_auth_username
      assert_nil importer.basic_auth_password
    end

    def test_distributors_ostree
      ostree_repo = katello_repositories(:ostree)
      depth = 100
      ostree_repo.root.expects(:compute_ostree_upstream_sync_depth).returns(depth)
      distributors = ostree_repo.generate_distributors
      assert 1, distributors.size
      assert_equal depth, distributors.first.depth
    end

    def test_importer_ostree
      ostree_repo = katello_repositories(:ostree)
      depth = 100
      ostree_repo.root.expects(:compute_ostree_upstream_sync_depth).returns(depth)
      importer = ostree_repo.generate_importer
      assert_equal depth, importer.depth
    end

    def test_importer_ostree_capsule
      ::Cert::Certs.stubs(:ueber_cert).returns(:cert => 'foo', :key => 'bar')
      capsule = FactoryBot.build(:smart_proxy, :pulp_mirror)
      ostree_repo = katello_repositories(:ostree)
      ostree_repo.root.expects(:compute_ostree_upstream_sync_depth).never

      importer = ostree_repo.generate_importer(capsule)
      assert_equal Katello::Pulp::Repository::Ostree::PULP_MIRROR_SYNC_DEPTH, importer.depth
    end

    def test_importer_matches?
      capsule = ::SmartProxy.new(:download_policy => 'on_demand')
      yum_config = {
        'feed' => 'http://foobar.com',
        'download_policy' => 'on_demand',
        'remove_missing' => true
      }
      @fedora_17_x86_64.expects(:generate_importer).with(capsule).at_least_once.returns(Runcible::Models::YumImporter.new(yum_config))

      assert @fedora_17_x86_64.importer_matches?({'importer_type_id' => Runcible::Models::YumImporter::ID, 'config' => yum_config}, capsule)
      refute @fedora_17_x86_64.importer_matches?({'importer_type_id' => Runcible::Models::DockerImporter::ID, 'config' => yum_config}, capsule)
      refute @fedora_17_x86_64.importer_matches?(nil, capsule)

      yum_config['some_other_attribute'] = 'asdf'
      refute @fedora_17_x86_64.importer_matches?({'importer_type_id' => Runcible::Models::YumImporter::ID, 'config' => yum_config}, capsule)
    end

    def test_pulp_scratchpad_checksum_type
      repo = katello_repositories(:fedora_17_x86_64)

      repo.stubs(:pulp_repo_facts)
      repo.stubs(:distributors).
        returns([{ "distributor_type_id" => Runcible::Models::YumDistributor.type_id }])

      assert_nil repo.pulp_scratchpad_checksum_type

      repo.stubs(:pulp_repo_facts).returns("scratchpad" => {"checksum_type" => SHA1})
      repo.stubs(:distributors).
        returns([{ "config" => {},
                   "distributor_type_id" => Runcible::Models::YumDistributor.type_id }])

      assert_equal repo.pulp_scratchpad_checksum_type, SHA1
    end
  end

  class GluePulpRepoTestCreateDestroy < GluePulpRepoTestBase
    def setup
      super
      @fedora_17_x86_64 = @fedora_17_x86_64
    end
  end

  class GluePulpRepoTest < GluePulpRepoTestBase
    def setup
      super
      RepositorySupport.create_repo(@fedora_17_x86_64)
      @fedora_17_x86_64 = @fedora_17_x86_64
      @fedora_17_x86_64.relative_path = 'test_path/'
      @mirror_proxy = FactoryBot.build(:smart_proxy, :pulp_mirror)
    end

    def teardown
      RepositorySupport.destroy_repo(@fedora_17_x86_64)
    end

    def test_delete_orphaned_content
      assert Repository.delete_orphaned_content.is_a?(Hash)
    end

    def test_generate_distributors_with_nil
      dists = @fedora_17_x86_64.generate_distributors
      refute_empty dists.select { |d| d.is_a? Runcible::Models::YumDistributor }
      refute_empty dists.select { |d| d.is_a? Runcible::Models::YumCloneDistributor }
      refute_empty dists.select { |d| d.is_a? Runcible::Models::ExportDistributor }
    end

    def test_generate_distributors_with_external_capsule
      dists = @fedora_17_x86_64.generate_distributors(@mirror_proxy)
      refute_empty dists.select { |d| d.is_a? Runcible::Models::YumDistributor }
      assert_empty dists.select { |d| d.is_a? Runcible::Models::YumCloneDistributor }
      assert_empty dists.select { |d| d.is_a? Runcible::Models::ExportDistributor }
    end

    def test_generate_distributors_with_default_capsule
      dists = @fedora_17_x86_64.generate_distributors(@primary_proxy)
      refute_empty dists.select { |d| d.is_a? Runcible::Models::YumDistributor }
      refute_empty dists.select { |d| d.is_a? Runcible::Models::YumCloneDistributor }
      refute_empty dists.select { |d| d.is_a? Runcible::Models::ExportDistributor }
    end

    def test_custom_repo_path
      @fedora_17_x86_64.organization.stubs(:label).returns("ACME")
      @fedora_17_x86_64.root.label = 'test'
      assert_equal "ACME/library_label/custom/fedora_label/test",
        @fedora_17_x86_64.custom_repo_path

      @fedora_17_x86_64.environment = nil
      assert_nil @fedora_17_x86_64.custom_repo_path
    end

    def test_pulp_scratchpad_checksum_type
      repo = katello_repositories(:rhel_7_x86_64)
      RepositorySupport.create_repo(repo)

      assert_nil repo.pulp_scratchpad_checksum_type

      assert_nil ::Katello.pulp_server.extensions
        .repository.delete(repo.pulp_id).parsed_body['error']
    end
  end

  class GluePulpRepoContentsTest < GluePulpRepoTestBase
    def setup
      super
      RepositorySupport.create_repo(@fedora_17_x86_64)
      RepositorySupport.sync_repo(@fedora_17_x86_64)
    end

    def teardown
      RepositorySupport.destroy_repo(@fedora_17_x86_64)
    end

    def test_sync_status
      assert_kind_of PulpSyncStatus, @fedora_17_x86_64.sync_status
    end

    def test_sync_state
      assert_equal PulpSyncStatus::FINISHED, @fedora_17_x86_64.sync_state
    end

    def test_successful_sync?
      assert @fedora_17_x86_64.successful_sync?(@fedora_17_x86_64.sync_status)
    end

    def test_synced?
      assert @fedora_17_x86_64.synced?
    end

    def test_import_distribution_data
      @fedora_17_x86_64.import_distribution_data

      assert_equal @fedora_17_x86_64.distribution_version, "16", "couldn't find version"
      assert_equal @fedora_17_x86_64.distribution_arch, "x86_64", "couldn't find arch"
      assert_equal @fedora_17_x86_64.distribution_family, "Test Family", "couldn't find family"
      assert_equal @fedora_17_x86_64.distribution_variant, "TestVariant", "couldn't find variant"
      assert_equal @fedora_17_x86_64.distribution_bootable, false, "couldn't find bootable"
    end

    def test_distribution_bootable?
      assert_equal @fedora_17_x86_64.distribution_bootable?, true
    end

    def test_package_groups
      @fedora_17_x86_64 = katello_repositories(:fedora_17_x86_64)
      package_groups = @fedora_17_x86_64.package_groups

      refute_empty package_groups.select { |group| group.name == 'mammals' }
    end
  end

  class GluePulpRepoOperationsTest < GluePulpRepoTestBase
    def setup
      super

      @fedora_17_x86_64_dev = katello_repositories(:fedora_17_x86_64_dev)

      RepositorySupport.create_repo(@fedora_17_x86_64)
      RepositorySupport.sync_repo(@fedora_17_x86_64)
    end

    def teardown
      RepositorySupport.destroy_repo(@fedora_17_x86_64)
    end

    def test_published
      assert @fedora_17_x86_64.published?
    end
  end
end
