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
require './test/support/pulp/repository_support'
require './test/support/pulp/user_support'


class GluePulpConsumerTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures
  include RepositorySupport

  fixtures :all

  def self.before_suite
    @loaded_fixtures = load_fixtures
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['System', 'Repository', 'User']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
  end

end


class GluePulpConsumerCreateTest < GluePulpConsumerTestBase

  def setup
    VCR.insert_cassette('pulp/consumer/create')
    @simple_server = System.find(systems(:simple_server).id)
  end

  def teardown
    VCR.eject_cassette
  end

  def test_set_pulp_consumer
    assert @simple_server.set_pulp_consumer
    @simple_server.del_pulp_consumer
  end

end


class GluePulpConsumerDeleteTest < GluePulpConsumerTestBase

  def setup
    VCR.insert_cassette('pulp/consumer/delete')
    @simple_server = System.find(systems(:simple_server).id)
    @simple_server.set_pulp_consumer
  end

  def teardown
    VCR.eject_cassette
  end

  def test_del_pulp_consumer
    assert @simple_server.del_pulp_consumer
  end

  def test_rollback_on_pulp_create
    assert @simple_server.rollback_on_pulp_create
  end

end


class GluePulpConsumerTest < GluePulpConsumerTestBase

  def setup
    VCR.insert_cassette('pulp/consumer/consumer')
    @simple_server = System.find(systems(:simple_server).id)
    @simple_server.set_pulp_consumer
  end

  def teardown
    @simple_server.del_pulp_consumer
    VCR.eject_cassette
  end

  def test_update_pulp_consumer
    @simple_server.name = "Not So Simple Server"

    assert_equal @simple_server.update_pulp_consumer['display_name'], "Not So Simple Server"
  end

  def test_upload_package_profile
    profile = [{"vendor" => "FedoraHosted", "name" => "elephant",
                 "version" => "0.3", "release" => "0.8",
                 "arch" => "noarch"}]

    assert @simple_server.upload_package_profile(profile)
  end

end


class GluePulpConsumerBindTest < GluePulpConsumerTestBase

  def self.before_suite
    super
    VCR.insert_cassette('pulp/consumer/bind')

    Pulp::UserSupport.setup_hidden_user
    RepositorySupport.create_and_sync_repo(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])

    @@simple_server = System.find(@loaded_fixtures['systems']['simple_server']['id'])
    @@simple_server.set_pulp_consumer
  end

  def self.after_suite
    Pulp::UserSupport.delete_hidden_user
    RepositorySupport.destroy_repo
    @@simple_server.del_pulp_consumer
    VCR.eject_cassette
  end

  def test_enable_repos
    processed_ids, error_ids = @@simple_server.enable_repos([RepositorySupport.repo.pulp_id])

    assert_includes processed_ids, RepositorySupport.repo.pulp_id
    refute_includes error_ids, RepositorySupport.repo.pulp_id
  end

end


class GluePulpConsumerContentTest < GluePulpConsumerTestBase

  def self.before_suite
    super
    VCR.insert_cassette('pulp/consumer/content')

    Pulp::UserSupport.setup_hidden_user
    RepositorySupport.create_and_sync_repo(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])

    @@simple_server = System.find(@loaded_fixtures['systems']['simple_server']['id'])
    @@simple_server.set_pulp_consumer
    @@simple_server.enable_repos([RepositorySupport.repo.pulp_id])
  end

  def self.after_suite
    Pulp::UserSupport.delete_hidden_user
    RepositorySupport.destroy_repo
    @@simple_server.del_pulp_consumer
    VCR.eject_cassette
  end

  def test_install_package
    task = @@simple_server.install_package(['elephant'])
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_install'
  end

  def test_uninstall_package
    task = @@simple_server.install_package(['cheetah'])
    TaskSupport.wait_on_task(task)

    task = @@simple_server.uninstall_package(['cheetah'])
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_uninstall'
  end

  def test_update_package
    task = @@simple_server.install_package(['cheetah'])
    TaskSupport.wait_on_task(task)

    task = @@simple_server.update_package(['cheetah'])
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_update'
  end

  def test_update_all_packages
    task = @@simple_server.install_package(['cheetah'])
    TaskSupport.wait_on_task(task)

    task = @@simple_server.update_package([])
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_update'
  end

  def test_install_package_group
    task = @@simple_server.install_package_group(['mammls'])
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_install'
  end

  def test_uninstall_package_group
    task = @@simple_server.install_package_group(['mammals'])
    TaskSupport.wait_on_task(task)

    task = @@simple_server.uninstall_package_group(['mammals'])
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_uninstall'
  end

  def test_install_consumer_errata
    erratum_id = RepositorySupport.repo.errata.select{ |errata| errata.errata_id == 'RHEA-2010:0002' }.first.id
    task = @@simple_server.install_consumer_errata([erratum_id])
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_install'
  end

end
