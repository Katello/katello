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
require './test/support/repository_support'
require './test/support/consumer_support'


class GluePulpConsumerGroupTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend  ActiveRecord::TestFixtures
  include RepositorySupport
  include ConsumerSupport

  fixtures :all

  def self.before_suite
    @loaded_fixtures = load_fixtures
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['System', 'Repository', 'SystemGroup']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    VCR.insert_cassette('glue_pulp_consumer_group', :match_requests_on => [:path, :params, :method, :body_json])
  end

  def self.after_suite
    VCR.eject_cassette
  end

end


class GluePulpConsumerGroupTestCreate < GluePulpConsumerGroupTestBase

  def setup
    @simple_server  = ConsumerSupport.create_consumer(systems(:simple_server).id)
    @simple_group   = SystemGroup.find(system_groups(:simple_group).id)
  end

  def teardown
    ConsumerSupport.destroy_consumer(@simple_server.id)
    @simple_group.del_pulp_consumer_group
  rescue RestClient::ResourceNotFound => e
    #ignore if not found
  end

  def test_set_pulp_consumer_group
    assert @simple_group.set_pulp_consumer_group
  end

end


class GluePulpConsumerGroupTest < GluePulpConsumerGroupTestBase

  def setup
    @simple_server  = ConsumerSupport.create_consumer(systems(:simple_server).id)
    @simple_group   = SystemGroup.find(system_groups(:simple_group).id)
    @simple_group.set_pulp_consumer_group
  end

  def teardown
    ConsumerSupport.destroy_consumer(@simple_server.id)
    Runcible::Resources::ConsumerGroup.retrieve(@simple_group.pulp_id)
    @simple_group.del_pulp_consumer_group
  rescue RestClient::ResourceNotFound => e
    #do nothing
  end

  def test_del_pulp_consumer_group
    assert @simple_group.del_pulp_consumer_group
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

  @@simple_server = nil

  def self.before_suite
    super
    RepositorySupport.create_and_sync_repo(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])

    @@simple_server = ConsumerSupport.create_consumer(@loaded_fixtures['systems']['simple_server']['id'])
    @@simple_server.enable_repos([RepositorySupport.repo_id])
  end

  def self.after_suite
    ConsumerSupport.destroy_consumer
    RepositorySupport.destroy_repo
    super
  end

  def test_install_package
    skip "Needs corresponding Runcible call once fixed in Pulp"
    assert false
  end

  def test_uninstall_package
    skip "Needs corresponding Runcible call once fixed in Pulp"
    assert false
  end

  def test_update_package
    skip "Needs corresponding Runcible call once fixed in Pulp"
    assert false
  end

  def test_install_package_group
    skip "Needs corresponding Runcible call once fixed in Pulp"
    assert false
  end

  def test_uninstall_package_group
    skip "Needs corresponding Runcible call once fixed in Pulp"
    assert false
  end

  def test_install_consumer_errata
    skip "Needs corresponding Runcible call once fixed in Pulp"
    assert false
  end

end
