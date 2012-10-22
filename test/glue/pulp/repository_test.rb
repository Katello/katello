#
# Copyright 2012 Red Hat, Inc.
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


module GluePulpRepoTestBase
  def self.included(base)
    base.class_eval do
      fixtures :all
    end

    base.extend ClassMethods
  end

  module ClassMethods
    def before_suite
      configure_vcr
      configure_runcible

      services  = ['Candlepin', 'ElasticSearch']
      models    = ['Repository', 'Package']
      disable_glue_layers(services, models)
    end
  end

  def setup
    @fedora_17          = Repository.find(repositories(:fedora_17).id)
    @fedora_17_dev      = Repository.find(repositories(:fedora_17_dev).id)
    @fedora             = Product.find(products(:fedora).id)
    @library            = KTEnvironment.find(environments(:library).id)
    @dev                = KTEnvironment.find(environments(:dev).id)
    @staging            = KTEnvironment.find(environments(:staging).id)
    @acme_corporation   = Organization.find(organizations(:acme_corporation).id)
    @unassigned_gpg_key = GpgKey.find(gpg_keys(:unassigned_gpg_key).id)
    @fedora_filter      = Filter.find(filters(:fedora_filter).id)
    @admin              = User.find(users(:admin).id)

    @fedora_17.relative_path = '/test_path/'
    @fedora_17.feed = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("glue/pulp", "fixtures/zoo5")

    VCR.insert_cassette('glue_pulp_repo')
  end

  def wait_on_tasks(task_list)
    task_list.each do |task|
      while !(['finished', 'error', 'timed_out', 'canceled', 'reset', 'success'].include?(task['state'])) do
        task = PulpSyncStatus.using_pulp_task(Runcible::Resources::Task.poll(task["task_id"]))
        sleep 0.1 # do not overload backend engines
      end
    end
  end

  def wait_on_task(task)
    while !(['finished', 'error', 'timed_out', 'canceled', 'reset', 'success'].include?(task['state'])) do
      task = PulpSyncStatus.using_pulp_task(Runcible::Resources::Task.poll(task["uuid"]))
      sleep 0.1 # do not overload backend engines
    end
  end

  def teardown
    VCR.use_cassette('glue_pulp_repo_helper') do
      @fedora_17.destroy_repo
    end
  rescue
  ensure
    VCR.eject_cassette
  end

end


class GluePulpRepoTestCreateDestroy < MiniTest::Rails::ActiveSupport::TestCase
  include GluePulpRepoTestBase

  def test_create_pulp_repo
    assert @fedora_17.create_pulp_repo
  end

  def test_destroy_repo
    @fedora_17.create_pulp_repo
    assert @fedora_17.destroy_repo
  end

end

class GluePulpRepoTest < MiniTest::Rails::ActiveSupport::TestCase
  include GluePulpRepoTestBase

  def setup
    super
    User.current = @admin
    @fedora_17.create_pulp_repo
  end

  def test_sync
    task_list = @fedora_17.sync
    assert task_list.length > 0
    assert task_list.first.is_a? PulpSyncStatus
    @task = task_list.first
    wait_on_task(@task)
  end

  def test_set_sync_schedule
    assert @fedora_17.set_sync_schedule(Time.now.advance(:years => 1).iso8601 << "/P1D")
  end

  def test_cancel_sync
    @fedora_17.sync
    assert @fedora_17.cancel_sync
  end

  def test_relative_path
    assert @fedora_17.relative_path == '/test_path/'
  end

  def test_relative_path=
    @fedora_17.relative_path = '/new_path/'
    assert @fedora_17.relative_path != '/test_path/'
  end

  def test_generate_distributor
    assert @fedora_17.generate_distributor.is_a? Runcible::Extensions::YumDistributor
  end

  def test_repo_id
    repo_id = Glue::Pulp::Repo.repo_id(@fedora.label, @fedora_17.label, @library.label, @acme_corporation.label)
    assert repo_id == "acme_corporation_label-library_label-fedora_label-fedora_17_label"
  end

  def test_populate_from
    assert @fedora_17.populate_from({ @fedora_17.pulp_id => @fedora_17 })
  end

end


class GluePulpRepoRequiresSyncTest < MiniTest::Rails::ActiveSupport::TestCase
  include GluePulpRepoTestBase

  def setup
    super
    User.current = @admin
    @fedora_17.create_pulp_repo
    task = @fedora_17.sync.first
    wait_on_task(task)
  end

  def test_last_sync
    assert @fedora_17.last_sync
  end

  def test_generate_metadata
    assert @fedora_17.generate_metadata
  end

  def test_sync_status
    assert @fedora_17.sync_status.is_a? PulpSyncStatus
  end

  def test_sync_state
    assert @fedora_17.sync_state == ::PulpSyncStatus::SUCCESS
  end

  def test_successful_sync?
    assert @fedora_17.successful_sync?(@fedora_17.sync_status)
  end

  def test_synced?
    assert @fedora_17.synced?
  end

  def test_sync_finish
    assert !@fedora_17.sync_finish.nil?
  end

  def test_sync_start
    assert !@fedora_17.sync_start.nil?
  end

  def test_packages
    assert @fedora_17.packages.select { |package| package.name == 'elephant' }.length > 0
  end

  def test_has_package?
    pkg_id = @fedora_17.packages.first.id
    assert @fedora_17.has_package?(pkg_id)
  end

  def test_errata
    assert @fedora_17.errata.select { |errata| errata.id == "RHEA-2010:0002" }.length > 0
  end

  def test_has_erratum?
    assert @fedora_17.has_erratum?("RHEA-2010:0002")
  end

  def test_distributions
    assert @fedora_17.distributions.select { |distribution| distribution.id == "ks-Test Family-TestVariant-16-x86_64" }.length > 0
  end

  def test_has_distribution?
    assert @fedora_17.has_distribution?("ks-Test Family-TestVariant-16-x86_64")
  end

  def test_find_packages_by_name
    assert @fedora_17.find_packages_by_name('elephant').length > 0
  end

  def test_find_packages_by_nvre
    assert @fedora_17.find_packages_by_nvre('elephant', '0.3', '0.8', '0').length > 0
  end

  def test_find_latest_packages_by_name
    assert @fedora_17.find_latest_packages_by_name('elephant').length > 0
  end

  def test_package_groups
    assert @fedora_17.package_groups.include?('mammals')
  end

  def test_package_group_categories
    categories = @fedora_17.package_group_categories
    assert categories.length > 0
    assert categories.include?('bird')
  end

  def test_create_clone
    clone = @fedora_17.create_clone(@staging)
    assert clone.is_a? Repository
    clone.destroy_repo
  end

  def test_clone_contents
    @fedora_17_dev.relative_path = Glue::Pulp::Repos.clone_repo_path(@fedora_17, @dev)
    @fedora_17_dev.create_pulp_repo
    task_list = @fedora_17.clone_contents(@fedora_17_dev)
    assert task_list.length == 3
    wait_on_tasks(task_list)
    @fedora_17_dev.destroy_repo
  end

  def test_promote
    task_list = @fedora_17.promote(@library, @staging)
    assert task_list.length == 3
    wait_on_tasks(task_list)
    clone_id = @fedora_17.clone_id(@staging)
    cloned_repo = Repository.where(:pulp_id => clone_id).first
    cloned_repo.destroy_repo
  end


end


class GluePulpRepoRequiresSyncAndPromoteTest < MiniTest::Rails::ActiveSupport::TestCase
  include GluePulpRepoTestBase

  def setup
    super
    User.current = @admin

    begin
      @fedora_17.destroy_repo
    rescue
    end

    clone_id = @fedora_17.clone_id(@staging)

    begin
      Runcible::Resources::Repository.delete(clone_id)
    rescue
    end

    @fedora_17.create_pulp_repo
    task = @fedora_17.sync.first
    wait_on_task(task)
    task_list = @fedora_17.promote(@library, @staging)
    wait_on_tasks(task_list)
    @cloned_repo = Repository.where(:pulp_id => clone_id).first
  end
  
  def teardown
    @cloned_repo.destroy_repo
    super
  end

  def test_delete_errata
    assert @cloned_repo.delete_errata(["RHEA-2010:0002"])
  end

  def test_delete_distribution
    assert @cloned_repo.delete_distribution("ks-Test Family-TestVariant-16-x86_64")
  end

end


class GluePulpRepoRequiresPromoteTest < MiniTest::Rails::ActiveSupport::TestCase
  include GluePulpRepoTestBase

  def setup
    super
    User.current = @admin

    begin
      @fedora_17.destroy_repo
    rescue
    end
    
    clone_id = @fedora_17.clone_id(@staging)
    begin
      Runcible::Resources::Repository.delete(clone_id)
    rescue
    end

    @fedora_17.create_pulp_repo
    task_list = @fedora_17.promote(@library, @staging)
    wait_on_tasks(task_list)

    task = @fedora_17.sync.first
    wait_on_task(task)

    @cloned_repo = Repository.where(:pulp_id => clone_id).first
  end
  
  def teardown
    @cloned_repo.destroy_repo
    super
  end

  def test_add_packages
    package = @fedora_17.find_packages_by_name('elephant').first
    assert @cloned_repo.add_packages([package.id])
  end

  def test_add_errata
    assert @cloned_repo.add_errata(["RHEA-2010:0002"])
  end

  def test_add_distribution
    assert @cloned_repo.add_distribution("ks-Test Family-TestVariant-16-x86_64")
  end

end
