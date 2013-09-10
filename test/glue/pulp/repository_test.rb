#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'

class GluePulpRepoTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures

  fixtures :all
  @@admin = nil

  def self.before_suite
    @loaded_fixtures = load_fixtures
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['KTEnvironment', 'Repository', 'Package', 'ContentView',
                 'Organization', 'Product', 'ContentViewEnvironment']
    disable_glue_layers(services, models, true)

    @@admin = User.find(@loaded_fixtures['users']['admin']['id'])
  end

  def self.wait_on_tasks(task_list)
    VCR.use_cassette('glue_pulp_repo_tasks', :erb => true, :match_requests_on => [:path, :method]) do
      task_list.each do |task|
        while !(['finished', 'error', 'timed_out', 'canceled', 'reset', 'success'].include?(task['state'])) do
          task = PulpSyncStatus.pulp_task(Katello.pulp_server.resources.task.poll(task["task_id"]))
          sleep 0.5 # do not overload backend engines
        end
      end
    end
  end

  def self.wait_on_task(task)
    VCR.use_cassette('glue_pulp_repo_tasks', :erb => true, :match_requests_on => [:path, :method]) do
      while !(['finished', 'error', 'timed_out', 'canceled', 'reset', 'success'].include?(task['state'])) do
        task = PulpSyncStatus.pulp_task(Katello.pulp_server.resources.task.poll(task["uuid"]))
        sleep 0.5 # do not overload backend engines
      end
    end
  end

  def setup
    VCR.insert_cassette('glue_pulp_repo', :match_requests_on => [:path, :params, :method])
  end

  def teardown
    VCR.eject_cassette
  end

end

class GluePulpRepoTestCreateDestroy < GluePulpRepoTestBase

  def setup
    super
    @fedora_17_x86_64 = Repository.find(repositories(:fedora_17_x86_64).id)
    @fedora_17_x86_64.relative_path = '/test_path/'
    @fedora_17_x86_64.feed = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("glue/pulp", "fixtures/zoo5")
  end

  def test_create_pulp_repo
    assert @fedora_17_x86_64.create_pulp_repo
    @fedora_17_x86_64.destroy_repo
  end

  def test_destroy_repo
    @fedora_17_x86_64.create_pulp_repo
    assert @fedora_17_x86_64.destroy_repo
  end

end

class GluePulpRepoTest < GluePulpRepoTestBase

  @@fedora_17_x86_64 = nil

  def self.before_suite
    super
    @@fedora_17_x86_64 = Repository.find(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])
    @@fedora_17_x86_64.relative_path = '/test_path/'
    @@fedora_17_x86_64.feed = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("glue/pulp", "fixtures/zoo5")

    VCR.use_cassette('glue_pulp_repo_helper') do
      @@fedora_17_x86_64.create_pulp_repo
    end
  end

  def self.after_suite
    VCR.use_cassette('glue_pulp_repo_helper') do
      @@fedora_17_x86_64.destroy_repo
    end
  end

  def setup
    super
    User.current = @@admin
    @fedora_17_x86_64 = @@fedora_17_x86_64
    @fedora_17_x86_64.relative_path = '/test_path/'
  end

  def test_sync
    task_list = @fedora_17_x86_64.sync

    refute_empty    task_list
    assert_kind_of  PulpSyncStatus, task_list.first

    @task = task_list.first
    self.class.wait_on_task(@task)
  end

  def test_set_sync_schedule
    VCR.use_cassette('glue_pulp_repo_sync_schedule', :match_requests_on => [:path, :params, :method]) do
      assert @fedora_17_x86_64.set_sync_schedule(Time.now.advance(:years => 1).iso8601 << "/P1D")
    end
  end

  def test_cancel_sync
    #@@fedora_17_x86_64.sync
    #assert @@fedora_17_x86_64.cancel_sync
  end

  def test_relative_path
    assert_equal '/test_path/', @fedora_17_x86_64.relative_path
  end

  def test_relative_path=
    @fedora_17_x86_64.relative_path = '/new_path/'

    refute_equal '/test_path/', @fedora_17_x86_64.relative_path
  end

  def test_generate_distributors
    dists = @fedora_17_x86_64.generate_distributors
    refute_empty dists.select{|d| d.is_a? Runcible::Models::YumDistributor}
    refute_empty dists.select{|d| d.is_a? Runcible::Models::YumCloneDistributor}
  end

  def test_populate_from
    assert @fedora_17_x86_64.populate_from({ @fedora_17_x86_64.pulp_id => {} })
  end

end

# TODO: uncomment this once runcible 1.0.4 or greater is out
#class GluePulpPuppetRepoTest < GluePulpRepoTestBase

  #@@p_forge = nil

  #def self.before_suite
    #super
    #@@p_forge = Repository.find(@loaded_fixtures['repositories']['p_forge']['id'])
    #@@p_forge.relative_path = '/test_path/'
    #@@p_forge.feed = "http://davidd.fedorapeople.org/repos/random_puppet/"

    #VCR.use_cassette('glue_pulp_repo_helper') do
      #@@p_forge.create_pulp_repo
    #end
  #end

  #def self.after_suite
    #VCR.use_cassette('glue_pulp_repo_helper') do
      #@@p_forge.destroy_repo
    #end
  #end

  #def setup
    #super
    #User.current = @@admin
    #@p_forge = @@p_forge
    #@p_forge.relative_path = '/test_path/'
  #end

  #def test_generate_distributors
    #refute_nil @@p_forge.find_distributor
  #end

#end

class GluePulpRepoRequiresSyncTest < GluePulpRepoTestBase

  i_suck_and_my_tests_are_order_dependent!

  @@fedora_17_x86_64 = nil
  @@fedora_17_x86_64_dev = nil

  def self.before_suite
    super
    User.current = @@admin
    @@fedora_17_x86_64 = Repository.find(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])
    @@fedora_17_x86_64_dev = Repository.find(@loaded_fixtures['repositories']['fedora_17_x86_64_dev']['id'])

    @@fedora_17_x86_64.relative_path = '/test_path/'
    @@fedora_17_x86_64.feed = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("glue/pulp", "fixtures/zoo5")

    VCR.use_cassette('glue_pulp_repo_helper') do
      @@fedora_17_x86_64.create_pulp_repo
      task = @@fedora_17_x86_64.sync.first
      wait_on_task(task)
    end
  end

  def self.after_suite
    VCR.use_cassette('glue_pulp_repo_helper') do
      @@fedora_17_x86_64.destroy_repo
    end
  end

  def test_last_sync
    assert @@fedora_17_x86_64.last_sync
  end

  def test_generate_metadata
    refute_empty @@fedora_17_x86_64.generate_metadata
  end

  def test_sync_status
    assert_kind_of PulpSyncStatus, @@fedora_17_x86_64.sync_status
  end

  def test_sync_state
    assert_equal ::PulpSyncStatus::FINISHED, @@fedora_17_x86_64.sync_state
  end

  def test_successful_sync?
    assert @@fedora_17_x86_64.successful_sync?(@@fedora_17_x86_64.sync_status)
  end

  def test_synced?
    assert @@fedora_17_x86_64.synced?
  end

  def test_sync_finish
    VCR.use_cassette('glue_pulp_repo_sync_status', :match_requests_on => [:path, :params, :method]) do
      refute_nil @@fedora_17_x86_64.sync_finish
    end
  end

  def test_sync_start
    VCR.use_cassette('glue_pulp_repo_sync_status', :match_requests_on => [:path, :params, :method]) do
      refute_nil @@fedora_17_x86_64.sync_start
    end
  end

  def test_packages
    VCR.use_cassette('glue_pulp_repo_units', :match_requests_on => [:body_json, :path, :method]) do
      refute_empty @@fedora_17_x86_64.packages.select { |package| package.name == 'elephant' }
    end
  end

  def test_has_package?
    VCR.use_cassette('glue_pulp_repo_units', :match_requests_on => [:body_json, :path, :method]) do
      pkg_id = @@fedora_17_x86_64.packages.sort_by(&:id).first.id
      assert @@fedora_17_x86_64.has_package?(pkg_id)
    end
  end

  def test_errata
    VCR.use_cassette('glue_pulp_repo_units', :match_requests_on => [:body_json, :path, :method]) do
      refute_empty @@fedora_17_x86_64.errata.select { |errata| errata.errata_id == "RHEA-2010:0002" }
    end
  end

  def test_has_erratum?
    VCR.use_cassette('glue_pulp_repo_units', :match_requests_on => [:body_json, :path, :method]) do
      e_id = @@fedora_17_x86_64.errata.first.errata_id
      assert @@fedora_17_x86_64.has_erratum?(e_id)
    end
  end

  def test_distributions
    VCR.use_cassette('glue_pulp_repo_units', :match_requests_on => [:body_json, :path, :method]) do
      distributions = @@fedora_17_x86_64.distributions

      refute_empty distributions.select { |distribution| distribution.id == "ks-Test Family-TestVariant-16-x86_64" }
    end
  end

  def test_has_distribution?
    VCR.use_cassette('glue_pulp_repo_units', :match_requests_on => [:body_json, :path, :method]) do
      assert @@fedora_17_x86_64.has_distribution?("ks-Test Family-TestVariant-16-x86_64")
    end
  end

  def test_find_packages_by_name
    refute_empty @@fedora_17_x86_64.find_packages_by_name('elephant')
  end

  def test_find_packages_by_nvre
    refute_empty @@fedora_17_x86_64.find_packages_by_nvre('elephant', '0.3', '0.8', '0')
  end

  def test_find_latest_packages_by_name
    refute_empty @@fedora_17_x86_64.find_latest_packages_by_name('elephant')
  end

  def test_package_groups
    VCR.use_cassette('glue_pulp_repo_units', :match_requests_on => [:body_json, :path, :method]) do
      package_groups = @@fedora_17_x86_64.package_groups

      refute_empty package_groups.select { |group| group.name == 'mammal' }
    end
  end

  def test_package_group_categories
    VCR.use_cassette('glue_pulp_repo_units', :match_requests_on => [:body_json, :path, :method]) do
      categories = @@fedora_17_x86_64.package_group_categories

      refute_empty categories.select { |category| category['name'] == 'all' }
    end
  end

  def test_create_clone
    staging = KTEnvironment.find(environments(:staging).id)
    clone = @@fedora_17_x86_64.create_clone(staging)

    assert_kind_of Repository, clone
  ensure
    clone.destroy
    assert_empty Repository.where(:id=>clone.id)
  end

  def test_clone_contents
    dev = KTEnvironment.find(environments(:dev).id)
    @@fedora_17_x86_64_dev.relative_path = Repository.clone_repo_path(@@fedora_17_x86_64, dev, dev.default_content_view)
    @@fedora_17_x86_64_dev.create_pulp_repo

    task_list = @@fedora_17_x86_64.clone_contents(@@fedora_17_x86_64_dev)
    assert_equal 5, task_list.length

    self.class.wait_on_tasks(task_list)
  ensure
    @@fedora_17_x86_64_dev.destroy_repo
  end

  def test_promote
    library = KTEnvironment.find(environments(:library).id)
    staging = KTEnvironment.find(environments(:staging).id)

    task_list = @@fedora_17_x86_64.promote(library, staging)
    assert_equal 5, task_list.length
    self.class.wait_on_tasks(task_list)

    clone_id = @@fedora_17_x86_64.clone_id(staging, staging.default_content_view)
    cloned_repo = Repository.where(:pulp_id => clone_id).first
    cloned_repo.destroy
  end

end

class GluePulpRepoRequiresEmptyPromoteTest < GluePulpRepoTestBase

  @@fedora_17_x86_64  = nil
  @@cloned_repo       = nil
  @@staging           = nil
  @@library           = nil

  def self.before_suite
    super
    User.current = @@admin

    @@fedora_17_x86_64 = Repository.find(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])
    @@fedora_17_x86_64.relative_path = '/test_path/'
    @@fedora_17_x86_64.feed = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("glue/pulp", "fixtures/zoo5")

    @@library = KTEnvironment.find(@loaded_fixtures['environments']['library']['id'])
    @@staging = KTEnvironment.find(@loaded_fixtures['environments']['staging']['id'])

    VCR.use_cassette('glue_pulp_repo_helper') do
      #clone_id = @@fedora_17_x86_64.clone_id(@@staging)
      #Runcible::Resources::Repository.delete(clone_id)
      ##@@fedora_17_x86_64.destroy_repo
      @@fedora_17_x86_64.create_pulp_repo
      task_list = @@fedora_17_x86_64.promote(@@library, @@staging)
      wait_on_tasks(task_list)

      task = @@fedora_17_x86_64.sync.first
      wait_on_task(task)

      clone_id = @@fedora_17_x86_64.clone_id(@@staging, @@staging.default_content_view)
      @@cloned_repo = Repository.where(:pulp_id => clone_id).first
    end
  end

  def self.after_suite
    VCR.use_cassette('glue_pulp_repo_helper') do
      @@cloned_repo.destroy if @@cloned_repo
      @@fedora_17_x86_64.destroy_repo if @@fedora_17_x86_64
    end
  end

  def test_add_packages
    package = @@fedora_17_x86_64.find_packages_by_name('elephant').first

    assert @@cloned_repo.add_packages([package['id']])
  end

  def test_add_errata
    assert @@cloned_repo.add_errata(["RHEA-2010:0002"])
  end

  def test_add_distribution
    assert @@cloned_repo.add_distribution("ks-Test Family-TestVariant-16-x86_64")
  end

end

class GluePulpRepoRequiresSyncAndPromoteTest < GluePulpRepoTestBase

  @@fedora_17_x86_64  = nil
  @@cloned_repo       = nil
  @@staging           = nil
  @@library           = nil

  def self.before_suite
    super
    User.current = @@admin

    @@fedora_17_x86_64 = Repository.find(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])
    @@fedora_17_x86_64.relative_path = '/test_path/'
    @@fedora_17_x86_64.feed = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("glue/pulp", "fixtures/zoo5")

    @@library = KTEnvironment.find(@loaded_fixtures['environments']['library']['id'])
    @@staging = KTEnvironment.find(@loaded_fixtures['environments']['staging']['id'])

    VCR.use_cassette('glue_pulp_repo_helper') do
      @@fedora_17_x86_64.create_pulp_repo
      task = @@fedora_17_x86_64.sync.first
      wait_on_task(task)

      task_list = @@fedora_17_x86_64.promote(@@library, @@staging)
      wait_on_tasks(task_list)

      clone_id = @@fedora_17_x86_64.clone_id(@@staging, @@staging.default_content_view)
      @@cloned_repo = Repository.where(:pulp_id => clone_id).first
    end
  end

  def self.after_suite
    VCR.use_cassette('glue_pulp_repo_helper') do
      @@fedora_17_x86_64.destroy_repo
      @@cloned_repo.destroy
    end
  end

  def test_delete_packages
    package = @@fedora_17_x86_64.find_packages_by_name('elephant').first

    assert @@cloned_repo.delete_packages([package['id']])
  end

  def test_delete_errata
    assert @@cloned_repo.delete_errata(["RHEA-2010:0002"])
  end

  def test_delete_distribution
    assert @@cloned_repo.delete_distribution("ks-Test Family-TestVariant-16-x86_64")
  end

end

class GluePulpRepoUploadContentTest < GluePulpRepoTestBase

  def setup
    @filepath = File.join(Rails.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz")
  end

  def test_upload_puppet_content
    content = mock(:create_upload_request => {"upload_id" => 1},
                   :upload_bits => true,
                   :import_into_repo => true,
                   :delete_upload_request => true)
    mock_resources = Class.new do
      define_method(:content) { content }
    end
    mock_server = Class.new do
      define_method(:resources) { mock_resources.new }
    end
    Katello.pulp_server = mock_server.new

    @pforge = Repository.find(repositories(:p_forge))
    @pforge.upload_content(@filepath)
  end
end
