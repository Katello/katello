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

require 'katello_test_helper'
require 'support/pulp/task_support'

module Katello
class GluePulpRepoTestBase < ActiveSupport::TestCase
  include TaskSupport

  def self.before_suite
    super
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['KTEnvironment', 'Repository', 'Package', 'ContentView',
                 'Organization', 'Product', 'ContentViewEnvironment']
    disable_glue_layers(services, models, true)

    @@fedora_17_x86_64 = Repository.find(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])
    @@fedora_17_x86_64.relative_path = '/test_path/'
    @@fedora_17_x86_64.feed = "file:///var/www/test_repos/zoo"
  end

end


class GluePulpRepoTestCreateDestroy < GluePulpRepoTestBase

  def setup
    super
    @fedora_17_x86_64 = @@fedora_17_x86_64
    VCR.insert_cassette('pulp/repository/create')
  end

  def teardown
    VCR.eject_cassette
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

  def self.before_suite
    super
    VCR.insert_cassette('pulp/repository/repository')
    @@fedora_17_x86_64.create_pulp_repo
  end

  def self.after_suite
    @@fedora_17_x86_64.destroy_repo
    VCR.eject_cassette
  end

  def setup
    super
    @fedora_17_x86_64 = @@fedora_17_x86_64
    @fedora_17_x86_64.relative_path = '/test_path/'
  end

  def test_delete_orphaned_content
    assert Repository.delete_orphaned_content.is_a?(Hash)
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

  def test_sync
    task_list = @fedora_17_x86_64.sync
    refute_empty    task_list
    assert_kind_of  PulpSyncStatus, task_list.first

    TaskSupport.wait_on_tasks(task_list)
  end

  def test_set_sync_schedule
    time = "2013-08-01T00:00:00-04:00/P1D"
    assert @fedora_17_x86_64.set_sync_schedule(time)
  end

end


class GluePulpRepoAfterSyncTest < GluePulpRepoTestBase

  def self.before_suite
    super
    VCR.insert_cassette('pulp/repository/after_sync')
    @@fedora_17_x86_64.create_pulp_repo
  end

  def self.after_suite
    @@fedora_17_x86_64.destroy_repo
    VCR.eject_cassette
  end

  def setup
    super
    @fedora_17_x86_64 = @@fedora_17_x86_64
    @fedora_17_x86_64.relative_path = '/test_path/'
  end

  def test_handle_sync_complete_task
    mock_notifier = Minitest::Mock.new
    mock_notifier.expect(:success, nil)

    task_list = @fedora_17_x86_64.sync
    TaskSupport.wait_on_tasks(task_list)

    @fedora_17_x86_64.handle_sync_complete_task(task_list.first.uuid, mock_notifier)

    assert PulpTaskStatus.where(:uuid => task_list.first.uuid).length > 0
  end

end


class GluePulpChangeFeedTest < GluePulpRepoTestBase

  def setup
    VCR.insert_cassette('pulp/repository/feed_change')
    @@fedora_17_x86_64.create_pulp_repo
  end

  def test_feed_change
    new_feed = "http://foo.com/foo"
    @@fedora_17_x86_64.feed = new_feed
    @@fedora_17_x86_64.save!
    pulps_feed = Repository.find(@@fedora_17_x86_64.id).pulp_repo_facts['importers'].first['config']['feed']
    assert_equal new_feed, pulps_feed
  end

  def teardown
    @@fedora_17_x86_64.destroy_repo
    VCR.eject_cassette
  end
end

class GluePulpPuppetRepoTest < GluePulpRepoTestBase

  @@p_forge = nil

  def self.before_suite
    super
    VCR.insert_cassette('pulp/repository/puppet')
    @@p_forge = Repository.find(@loaded_fixtures['katello_repositories']['p_forge']['id'])
    @@p_forge.relative_path = '/test_path/'
    @@p_forge.feed = "http://davidd.fedorapeople.org/repos/random_puppet/"
    @@p_forge.create_pulp_repo
  end

  def self.after_suite
    @@p_forge.destroy_repo
    VCR.eject_cassette
  end

  def setup
    super
    @p_forge = @@p_forge
    @p_forge.relative_path = '/test_path/'
  end

  def test_generate_distributors
    refute_nil @@p_forge.find_distributor
  end

  def test_upload_puppet_module
    Repository.any_instance.expects(:trigger_contents_changed).with() do |options|
      options[:wait] == false && options[:reindex] == false && options[:index_units].size > 0
    end

    @filepath = File.join(Katello::Engine.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz")
    @p_forge.upload_content(@filepath)
    assert_includes @p_forge.puppet_modules.map(&:name), "ntp"
  end
end



class GluePulpRepoContentsTest < GluePulpRepoTestBase

  def self.before_suite
    super
    VCR.insert_cassette('pulp/repository/contents')

    @@fedora_17_x86_64.create_pulp_repo
    task_list = @@fedora_17_x86_64.sync
    TaskSupport.wait_on_tasks(task_list)
  end

  def self.after_suite
    @@fedora_17_x86_64.destroy_repo
    VCR.eject_cassette
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
    assert_equal PulpSyncStatus::FINISHED, @@fedora_17_x86_64.sync_state
  end

  def test_successful_sync?
    assert @@fedora_17_x86_64.successful_sync?(@@fedora_17_x86_64.sync_status)
  end

  def test_synced?
    assert @@fedora_17_x86_64.synced?
  end

  def test_sync_finish
    refute_nil @@fedora_17_x86_64.sync_finish
  end

  def test_sync_start
    refute_nil @@fedora_17_x86_64.sync_start
  end

  def test_packages
    refute_empty @@fedora_17_x86_64.packages.select { |package| package.name == 'elephant' }
  end

  def test_has_package?
    pkg_id = @@fedora_17_x86_64.packages.sort_by(&:id).first.id
    assert @@fedora_17_x86_64.has_package?(pkg_id)
  end

  def test_errata
    refute_empty @@fedora_17_x86_64.errata.select { |errata| errata.errata_id == "RHEA-2010:0002" }
  end

  def test_has_erratum?
    e_id = @@fedora_17_x86_64.errata.first.errata_id
    assert @@fedora_17_x86_64.has_erratum?(e_id)
  end

  def test_distributions
    distributions = @@fedora_17_x86_64.distributions

    refute_empty distributions.select { |distribution| distribution.id == "ks-Test Family-TestVariant-16-x86_64" }
  end

  def test_has_distribution?
    assert @@fedora_17_x86_64.has_distribution?("ks-Test Family-TestVariant-16-x86_64")
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
    package_groups = @@fedora_17_x86_64.package_groups

    refute_empty package_groups.select { |group| group.name == 'mammal' }
  end

  def test_package_group_categories
    categories = @@fedora_17_x86_64.package_group_categories

    refute_empty categories.select { |category| category['name'] == 'all' }
  end

  def test_trigger_contents_changed_index_units
    Katello.config.stubs(:use_elasticsearch).returns(:true)
    pkg = @@fedora_17_x86_64.find_packages_by_nvre('elephant', '0.3', '0.8', '0')[0]
    @@fedora_17_x86_64.expects(:generate_metadata).returns([])
    Package.expects(:index_packages).with([pkg['_id']])

    unit = {:checksumtype => pkg['checksumtype'], :checksum => pkg['checksum'] }
    @@fedora_17_x86_64.trigger_contents_changed(:publish => true, :reindex => false, :index_units => [unit])
  end

end


class GluePulpRepoOperationsTest < GluePulpRepoTestBase

  def self.before_suite
    super
    VCR.insert_cassette('pulp/repository/operations')

    @@fedora_17_x86_64_dev = Repository.find(@loaded_fixtures['katello_repositories']['fedora_17_x86_64_dev']['id'])

    @@fedora_17_x86_64.create_pulp_repo
    task_list = @@fedora_17_x86_64.sync
    TaskSupport.wait_on_tasks(task_list)
  end

  def self.after_suite
    @@fedora_17_x86_64.destroy_repo
    VCR.eject_cassette
  end

  def test_create_clone
    staging = KTEnvironment.find(katello_environments(:staging).id)
    clone = @@fedora_17_x86_64.create_clone(staging)

    assert_kind_of Repository, clone
  ensure
    clone.destroy
    assert_empty Repository.where(:id=>clone.id)
  end

  def test_clone_contents
    dev = KTEnvironment.find(katello_environments(:dev).id)
    @@fedora_17_x86_64_dev.relative_path = Repository.clone_repo_path(@@fedora_17_x86_64, dev, dev.default_content_view)
    @@fedora_17_x86_64_dev.create_pulp_repo

    task_list = @@fedora_17_x86_64.clone_contents(@@fedora_17_x86_64_dev)
    assert_equal 5, task_list.length

    TaskSupport.wait_on_tasks(task_list)
  ensure
    @@fedora_17_x86_64_dev.destroy_repo
  end

  def test_promote
    library = KTEnvironment.find(katello_environments(:library).id)
    staging = KTEnvironment.find(katello_environments(:staging).id)

    task_list = @@fedora_17_x86_64.promote(library, staging)
    assert_equal 5, task_list.length
    TaskSupport.wait_on_tasks(task_list)

    clone_id = @@fedora_17_x86_64.clone_id(staging, staging.default_content_view)
    cloned_repo = Repository.where(:pulp_id => clone_id).first
    cloned_repo.destroy
  end

end


class GluePulpRepoRequiresEmptyPromoteTest < GluePulpRepoTestBase


  @@cloned_repo = nil

  def self.before_suite
    super
    VCR.insert_cassette('pulp/repository/add_contents')

    @@library = KTEnvironment.find(@loaded_fixtures['katello_environments']['library']['id'])
    @@staging = KTEnvironment.find(@loaded_fixtures['katello_environments']['staging']['id'])

    @@fedora_17_x86_64.create_pulp_repo
    task_list = @@fedora_17_x86_64.sync
    TaskSupport.wait_on_tasks(task_list)

    #clone_id = @@fedora_17_x86_64.clone_id(@@staging, @@staging.default_content_view)
    #Runcible::Extensions::Repository.delete(clone_id)


    task = @@fedora_17_x86_64.promote(@@library, @@staging)
    TaskSupport.wait_on_tasks(task)

    clone_id = @@fedora_17_x86_64.clone_id(@@staging, @@staging.default_content_view)
    @@cloned_repo = Repository.where(:pulp_id => clone_id).first
  end

  def self.after_suite
    @@cloned_repo.destroy if @@cloned_repo
    @@fedora_17_x86_64.destroy_repo if @@fedora_17_x86_64
    VCR.eject_cassette
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
    VCR.insert_cassette('pulp/repository/remove_contents')

    @@library = KTEnvironment.find(@loaded_fixtures['katello_environments']['library']['id'])
    @@staging = KTEnvironment.find(@loaded_fixtures['katello_environments']['staging']['id'])

    @@fedora_17_x86_64.create_pulp_repo
    task_list = @@fedora_17_x86_64.sync
    TaskSupport.wait_on_tasks(task_list)

    task_list = @@fedora_17_x86_64.promote(@@library, @@staging)
    TaskSupport.wait_on_tasks(task_list)

    clone_id = @@fedora_17_x86_64.clone_id(@@staging, @@staging.default_content_view)
    @@cloned_repo = Repository.where(:pulp_id => clone_id).first
  end

  def self.after_suite
    @@cloned_repo.destroy if @@cloned_repo
    @@fedora_17_x86_64.destroy_repo if @@fedora_17_x86_64
    VCR.eject_cassette
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
end
