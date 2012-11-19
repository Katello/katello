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
require './test/support/repository_support'

class GluePulpConsumerTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend  ActiveRecord::TestFixtures
  include RepositorySupport

  fixtures :all

  def self.before_suite
    load_fixtures
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['System', 'Repository']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    #RepositorySupport.create_and_sync_repo(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])

    VCR.insert_cassette('glue_pulp_consumer', :match_requests_on => [:path, :params, :method, :body_json])
  end

  def self.after_suite
    VCR.eject_cassette
  end

end


class GluePulpConsumerTestCreateDestroy < GluePulpConsumerTestBase

  def setup
    super
    @simple_server = System.find(systems(:simple_server).id)
  end

  def test_set_pulp_consumer
    assert @simple_server.set_pulp_consumer
    @simple_server.del_pulp_consumer
  end

  def test_del_pulp_consumer
    @simple_server.set_pulp_consumer
    assert @simple_server.del_pulp_consumer
  end

end
