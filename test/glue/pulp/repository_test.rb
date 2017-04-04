require 'katello_test_helper'
require 'support/pulp/task_support'

module Katello
  class GluePulpRepoTestBase < ActiveSupport::TestCase
    include TaskSupport
    include Dynflow::Testing
    include Support::CapsuleSupport

    def setup
      set_user
      backend_stubs

      FactoryGirl.create(:smart_proxy, :default_smart_proxy)
      @fedora_17_x86_64_dev = Repository.find(FIXTURES['katello_repositories']['fedora_17_x86_64_dev']['id'])
      @fedora_17_x86_64 = Repository.find(FIXTURES['katello_repositories']['fedora_17_x86_64']['id'])
      @fedora_17_library_library_view = Repository.find(FIXTURES['katello_repositories']['fedora_17_library_library_view']['id'])
      @library_dev_staging_view = katello_content_views(:library_dev_staging_view)
      @cvpe_one = katello_content_view_puppet_environments(:archive_view_puppet_environment)
      @fedora_17_x86_64.relative_path = 'test_path/'
      @fedora_17_x86_64.url = "file:///var/www/test_repos/zoo"
    end

    def backend_stubs
      Product.any_instance.stubs(:certificate).returns(nil)
      Product.any_instance.stubs(:key).returns(nil)
    end

    def teardown
      VCR.eject_cassette
    end

    def self.delete_repo(repo)
      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Destroy, :pulp_id => repo.pulp_id)
    end

    def delete_repo(repo)
      GluePulpRepoTestBase.delete_repo(repo)
    end

    def create_repo(repo)
      GluePulpRepoTestBase.create_repo(repo)
    end

    def self.create_repo(repository)
      ::ForemanTasks.sync_task(::Actions::Pulp::Repository::Create,
                              content_type: repository.content_type,
                              pulp_id: repository.pulp_id,
                              name: repository.name,
                              feed: repository.url,
                              ssl_ca_cert: "foo",
                              ssl_client_cert: "foo",
                              ssl_client_key: "foo",
                              unprotected: repository.unprotected,
                              checksum_type: repository.checksum_type,
                              path: repository.relative_path,
                              with_importer: true)
    end
  end

  class GluePulpNonVcrTests < GluePulpRepoTestBase
    def test_importer_feed_url
      proxy = FactoryGirl.build(:bmc_smart_proxy)

      pulp_host = URI.parse(SETTINGS[:katello][:pulp][:url]).host
      repo = ::Katello::Repository.new(:url => 'http://zodiak.com/ted', :unprotected => false, :relative_path => '/elbow')

      assert_equal repo.importer_feed_url, 'http://zodiak.com/ted'
      assert_equal repo.importer_feed_url(proxy), "https://#{pulp_host}/pulp/repos//elbow/"

      repo.unprotected = true
      assert_equal repo.importer_feed_url(proxy), "https://#{pulp_host}/pulp/repos//elbow/"
    end

    def test_importer_ssl_options
      ::Cert::Certs.stubs(:ueber_cert).returns(:cert => 'foo', :key => 'bar')
      proxy = FactoryGirl.build(:bmc_smart_proxy)
      assert @fedora_17_x86_64.importer_ssl_options(proxy).key?(:ssl_validation)
      refute @cvpe_one.importer_ssl_options(proxy).key?(:ssl_validation)
    end

    def test_relative_path
      assert_equal 'test_path/', @fedora_17_x86_64.relative_path
    end

    def test_relative_path=
      @fedora_17_x86_64.relative_path = 'new_path/'

      refute_equal 'test_path/', @fedora_17_x86_64.relative_path
    end

    def test_populate_from
      assert @fedora_17_x86_64.populate_from(@fedora_17_x86_64.pulp_id => {})
    end

    def test_distributors_match_yum
      yum_config = {
        'relative_url' => '/foo/bar',
        'checksum_type' => nil,
        'http' => true,
        'https' => true
      }
      @fedora_17_x86_64.expects(:generate_distributors).with(capsule_content.capsule).at_least_once.returns(
          [Runcible::Models::YumDistributor.new('/foo/bar', true, true, yum_config)])

      assert @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::YumDistributor.type_id,
                                                     'config' => yum_config}], capsule_content.capsule)
      refute @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::YumCloneDistributor.type_id,
                                                     'config' => yum_config}], capsule_content.capsule)
      refute @fedora_17_x86_64.distributors_match?([], capsule_content.capsule)

      non_nil_checksum = yum_config.clone
      non_nil_checksum['checksum_type'] = 'sha256'
      assert @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::YumDistributor.type_id,
                                                     'config' => non_nil_checksum}], capsule_content.capsule)

      yum_config['relative_url'] = '/arrow/to/the/knee'
      refute @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::YumCloneDistributor.type_id,
                                                     'config' => yum_config}], capsule_content.capsule)
    end

    def test_distributors_match_docker
      docker_config = {
        'protected' => true
      }

      @fedora_17_x86_64.expects(:generate_distributors).with(capsule_content.capsule).at_least_once.returns(
          [Runcible::Models::DockerDistributor.new(docker_config)])

      assert @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::DockerDistributor.type_id,
                                                     'config' => docker_config}], capsule_content.capsule)
      docker_config['protected'] = false
      refute @fedora_17_x86_64.distributors_match?([{'distributor_type_id' => Runcible::Models::DockerDistributor.type_id,
                                                     'config' => docker_config}], capsule_content.capsule)
    end

    def test_importer_upstream_username_passwd
      repo = katello_repositories(:fedora_17_x86_64)
      username = "justin"
      password = "super-secret"
      repo.update_attributes!(:upstream_username => username, :upstream_password => password)
      importer = repo.generate_importer
      assert_equal username,  importer.basic_auth_username
      assert_equal password,  importer.basic_auth_password
    end

    def test_importer_upstream_username_passwd_with_capsule
      ::Cert::Certs.stubs(:ueber_cert).returns(:cert => 'foo', :key => 'bar')
      proxy = FactoryGirl.build(:bmc_smart_proxy)
      repo = katello_repositories(:fedora_17_x86_64)
      username = "justin"
      password = "super-secret"
      repo.update_attributes!(:upstream_username => username, :upstream_password => password)
      importer = repo.generate_importer(proxy)
      assert_nil importer.basic_auth_username
      assert_nil importer.basic_auth_password
    end

    def test_importer_matches?
      capsule = SmartProxy.new(:download_policy => 'on_demand')
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

    def test_pulp_update_needed_with_upstream_name_passwd?
      repo = katello_repositories(:fedora_17_x86_64)
      refute repo.pulp_update_needed?
      repo.upstream_username = 'amazing'
      repo.save!
      assert repo.pulp_update_needed?

      repo = katello_repositories(:fedora_17_x86_64).reload
      refute repo.pulp_update_needed?
      repo.upstream_password = 'amazing'
      repo.save!
      assert repo.pulp_update_needed?
    end
  end

  class GluePulpRepoTestCreateDestroy < GluePulpRepoTestBase
    def setup
      super
      @fedora_17_x86_64 = @fedora_17_x86_64
      VCR.insert_cassette('pulp/repository/create')
    end

    def test_create_pulp_repo
      assert create_repo(@fedora_17_x86_64)
      delete_repo(@fedora_17_x86_64)
    end
  end

  class GluePulpRepoTest < GluePulpRepoTestBase
    def setup
      super
      VCR.insert_cassette('pulp/repository/repository')
      self.create_repo(@fedora_17_x86_64)
      @fedora_17_x86_64 = @fedora_17_x86_64
      @fedora_17_x86_64.relative_path = 'test_path/'
    end

    def teardown
      delete_repo(@fedora_17_x86_64)
    ensure
      VCR.eject_cassette
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
      dists = @fedora_17_x86_64.generate_distributors(OpenStruct.new(:default_capsule? => false))
      refute_empty dists.select { |d| d.is_a? Runcible::Models::YumDistributor }
      assert_empty dists.select { |d| d.is_a? Runcible::Models::YumCloneDistributor }
      refute_empty dists.select { |d| d.is_a? Runcible::Models::ExportDistributor }
    end

    def test_generate_distributors_with_default_capsule
      dists = @fedora_17_x86_64.generate_distributors(OpenStruct.new(:default_capsule? => true))
      refute_empty dists.select { |d| d.is_a? Runcible::Models::YumDistributor }
      refute_empty dists.select { |d| d.is_a? Runcible::Models::YumCloneDistributor }
      refute_empty dists.select { |d| d.is_a? Runcible::Models::ExportDistributor }
    end

    def test_sync
      task_list = @fedora_17_x86_64.sync
      refute_empty task_list
      assert_kind_of PulpSyncStatus, task_list.first
      TaskSupport.wait_on_tasks(task_list)
    end

    def test_sync_schedule
      time = "2013-08-01T00:00:00-04:00/P1D"
      assert @fedora_17_x86_64.sync_schedule(time)
    end

    def test_custom_repo_path
      product = @fedora_17_x86_64.product
      env = @fedora_17_x86_64.product.organization.library
      env.organization.stubs(:label).returns("ACME")
      assert_nil Glue::Pulp::Repos.custom_repo_path(nil, product, "test")
      assert_equal "ACME/library_label/custom/fedora_label/test",
        Glue::Pulp::Repos.custom_repo_path(env, product, "test")
    end

    def test_pulp_update_needed?
      refute @fedora_17_x86_64.pulp_update_needed?

      @fedora_17_x86_64.url = 'https://www.google.com'
      @fedora_17_x86_64.save!
      assert @fedora_17_x86_64.pulp_update_needed?

      @fedora_17_x86_64.stubs(:redhat?).returns(true)

      @fedora_17_x86_64.url = 'https://www.yahoo.com'
      @fedora_17_x86_64.save!
      assert @fedora_17_x86_64.pulp_update_needed?
    end
  end

  class GluePulpPuppetRepoTest < GluePulpRepoTestBase
    @p_forge = nil

    def setup
      super
      VCR.insert_cassette('pulp/repository/puppet')
      @p_forge = Repository.find(FIXTURES['katello_repositories']['p_forge']['id'])
      @p_forge.relative_path = RepositorySupport::PULP_TMP_DIR
      @p_forge.url = "http://davidd.fedorapeople.org/repos/random_puppet/"
      create_repo(@p_forge)
      @p_forge = @p_forge
      ForemanTasks.sync_task(Actions::Pulp::Repository::DistributorPublish,
                             :pulp_id => @p_forge.pulp_id,
                             :distributor_type_id => Runcible::Models::PuppetInstallDistributor.type_id)
    end

    def teardown
      delete_repo(@p_forge)
    ensure
      VCR.eject_cassette
    end

    def test_generate_distributors
      refute_nil @p_forge.find_distributor
    end
  end

  class GluePulpRepoContentsTest < GluePulpRepoTestBase
    def setup
      super
      VCR.insert_cassette('pulp/repository/contents')

      @fedora_17_x86_64.create_pulp_repo
      task_list = @fedora_17_x86_64.sync
      TaskSupport.wait_on_tasks(task_list)
    end

    def teardown
      delete_repo(@fedora_17_x86_64)
    ensure
      VCR.eject_cassette
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

    def test_sync_finish
      refute_nil @fedora_17_x86_64.sync_finish
    end

    def test_sync_start
      refute_nil @fedora_17_x86_64.sync_start
    end

    def test_import_distribution_data
      @fedora_17_x86_64.import_distribution_data

      assert @fedora_17_x86_64.distribution_version == "16", "couldn't find version"
      assert @fedora_17_x86_64.distribution_arch == "x86_64", "couldn't find arch"
      assert @fedora_17_x86_64.distribution_family == "Test Family", "couldn't find family"
      assert @fedora_17_x86_64.distribution_variant == "TestVariant", "couldn't find variant"
      assert @fedora_17_x86_64.distribution_bootable == false, "couldn't find bootable"
    end

    def test_distribution_bootable?
      assert_equal @fedora_17_x86_64.distribution_bootable?, true
    end

    def test_class_distribution_bootable?
      assert ::Katello::Repository.distribution_bootable?('files' => [{:relativepath => '/foo/kernel.img'}])
      assert ::Katello::Repository.distribution_bootable?('files' => [{:relativepath => '/foo/initrd.img'}])
      assert ::Katello::Repository.distribution_bootable?('files' => [{:relativepath => '/bar/vmlinuz'}])
      assert ::Katello::Repository.distribution_bootable?('files' => [{:relativepath => '/bar/foo/pxeboot'}])
      refute ::Katello::Repository.distribution_bootable?('files' => [{:relativepath => '/bar/foo'}])
    end

    def test_find_packages_by_name
      refute_empty @fedora_17_x86_64.find_packages_by_name('elephant')
    end

    def test_find_packages_by_nvre
      refute_empty @fedora_17_x86_64.find_packages_by_nvre('elephant', '0.3', '0.8', '0')
    end

    def test_package_groups
      @fedora_17_x86_64 = Repository.find(FIXTURES['katello_repositories']['fedora_17_x86_64']['id'])
      package_groups = @fedora_17_x86_64.package_groups

      refute_empty package_groups.select { |group| group.name == 'mammals' }
    end
  end

  class GluePulpRepoOperationsTest < GluePulpRepoTestBase
    def setup
      super
      VCR.insert_cassette('pulp/repository/operations')

      @fedora_17_x86_64_dev = Repository.find(FIXTURES['katello_repositories']['fedora_17_x86_64_dev']['id'])

      @fedora_17_x86_64.create_pulp_repo
      task_list = @fedora_17_x86_64.sync
      TaskSupport.wait_on_tasks(task_list)
    end

    def teardown
      delete_repo(@fedora_17_x86_64)
    ensure
      VCR.eject_cassette
    end

    def test_create_clone
      dev = KTEnvironment.find(katello_environments(:dev).id)
      clone = @fedora_17_library_library_view.create_clone(:environment => dev, :content_view => @library_dev_staging_view)

      assert_kind_of Repository, clone
    ensure
      clone.destroy
      assert_empty Repository.where(:id => clone.id)
    end

    def test_clone_contents
      library = KTEnvironment.find(katello_environments(:library).id)
      @fedora_17_x86_64_dev.relative_path = Repository.clone_repo_path(:repository => @fedora_17_x86_64,
                                                                        :environment => library,
                                                                        :content_view => library.default_content_view)
      @fedora_17_x86_64_dev.create_pulp_repo

      task_list = @fedora_17_x86_64.clone_contents(@fedora_17_x86_64_dev)
      assert_equal 4, task_list.length

      TaskSupport.wait_on_tasks(task_list)
    ensure
      delete_repo(@fedora_17_x86_64_dev)
    end
  end
end
