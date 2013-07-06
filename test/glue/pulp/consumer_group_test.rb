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


class GluePulpConsumerGroupTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend  ActiveRecord::TestFixtures
  include RepositorySupport

  fixtures :all

  def self.before_suite
    @loaded_fixtures = load_fixtures
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['System', 'Repository', 'SystemGroup', 'User']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
  end

end


class GluePulpConsumerGroupCreateTest < GluePulpConsumerGroupTestBase

  def setup
    VCR.insert_cassette('pulp/consumer_group/create')
    @simple_group = SystemGroup.find(system_groups(:simple_group).id)
  end

  def teardown
    @simple_group.del_pulp_consumer_group
    VCR.eject_cassette
  end

  def test_set_pulp_consumer_group
    assert @simple_group.set_pulp_consumer_group
  end

end


class GluePulpConsumerGroupDeleteTest < GluePulpConsumerGroupTestBase

  def setup
    VCR.insert_cassette('pulp/consumer_group/delete')
    @simple_group   = SystemGroup.find(system_groups(:simple_group).id)
    @simple_group.set_pulp_consumer_group
  end

  def teardown
    VCR.eject_cassette
  end

  def test_del_pulp_consumer_group
    assert @simple_group.del_pulp_consumer_group
  end

end


class GluePulpConsumerGroupTest < GluePulpConsumerGroupTestBase

  def setup
    VCR.insert_cassette('pulp/consumer_group/delete')

    @simple_server  = System.find(systems(:simple_server).id)
    @simple_server.set_pulp_consumer

    @simple_group   = SystemGroup.find(system_groups(:simple_group).id)
    @simple_group.set_pulp_consumer_group
  end

  def teardown
    @simple_server.del_pulp_consumer
    @simple_group.del_pulp_consumer_group
    VCR.eject_cassette
  end

  def test_add_consumer
    assert @simple_group.add_consumer(@simple_server)
  end

  def test_add_consumers
    assert @simple_group.add_consumers([@simple_server.uuid])
  end

  def test_remove_consumer
    @simple_group.add_consumer(@simple_server)

    assert @simple_group.remove_consumer(@simple_server)
  end

  def test_remove_consumers
    @simple_group.add_consumer(@simple_server)

    assert @simple_group.remove_consumers([@simple_server.uuid])
  end

end


class GluePulpConsumerGroupRequiresBoundRepoTest < GluePulpConsumerGroupTestBase

  def setup
    VCR.insert_cassette('pulp/consumer_group/content')
    RepositorySupport.create_and_sync_repo(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])

    @simple_group   = SystemGroup.find(system_groups(:simple_group).id)
    @simple_group.set_pulp_consumer_group
  end

  def teardown
    RepositorySupport.destroy_repo
    @simple_group.del_pulp_consumer_group
    VCR.eject_cassette
  end

  def test_install_package
    job = @simple_group.install_package(['elephant'])
    task = job.first
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_install'
  end

  def test_uninstall_package
    job = @simple_group.uninstall_package(['cheetah'])
    task = job.first
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_uninstall'
  end

  def test_update_package
    job = @simple_group.update_package(['cheetah'])
    task = job.first
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_update'
  end

  def test_update_all_packages
    job = @simple_group.update_package([])
    task = job.first
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_update'
  end

  def test_install_package_group
    job = @simple_group.install_package_group(['mammals'])
    task = job.first
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_install'
  end

  def test_uninstall_package_group
    job = @simple_group.uninstall_package_group(['mammals'])
    task = job.first
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_uninstall'
  end

  def test_install_errata
    erratum_id = RepositorySupport.repo.errata.select{ |errata| errata.errata_id == 'RHEA-2010:0002' }.first.id
    job = @simple_group.install_consumer_errata([erratum_id])
    task = job.first
    TaskSupport.wait_on_task(task)

    assert_includes task['tags'], 'pulp:action:unit_install'
  end

end
