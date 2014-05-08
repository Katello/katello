#
# Copyright 2014 Red Hat, Inc.
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
require 'support/candlepin/consumer_support'

module Katello
class GlueCandlepinConsumerTestBase < ActiveSupport::TestCase
  include CandlepinConsumerSupport

  @@dev = nil
  @@org = nil
  @@dev_cv = nil
  @@dev_cve = nil

  def self.before_suite
    super

    services  = ['Pulp', 'ElasticSearch', 'Foreman']
    models    = ['System', 'LifecycleEnvironment', 'Organization', 'Product', 'ContentView', 'ContentViewEnvironment', 'ContentViewVersion', "Distributor"]
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    VCR.insert_cassette('glue_candlepin_consumer', :match_requests_on => [:path, :params, :method, :body_json])

    @@dev      = LifecycleEnvironment.find(@loaded_fixtures['katello_environments']['candlepin_dev']['id'])

    @@org      = Organization.find(@loaded_fixtures['taxonomies']['organization2']['id'])
    @@org.setup_label_from_name
    @@org.save

    @@dev_cv   = ContentView.find(@loaded_fixtures['katello_content_views']['candlepin_library_dev_cv']['id'])
    @@dev_cve  = ContentViewEnvironment.find(@loaded_fixtures['katello_content_view_environments']['candlepin_library_dev_cve']['id'])
    @@dev_cve.cp_id = @@dev_cv.cp_environment_id @@dev

    # Create the environment in candlepin
    CandlepinOwnerSupport.set_owner(@@org)

    User.current.remote_id =  User.current.login
    ForemanTasks.sync_task(::Actions::Katello::ContentView::EnvironmentCreate, @@dev_cve)
  end

  def self.after_suite
    @@dev_cve.del_environment unless @@dev_cve.nil?
    @@org.del_owner unless @@org.nil?
  ensure
    VCR.eject_cassette
  end

end

class GlueCandlepinConsumerTestSystem < GlueCandlepinConsumerTestBase

  def setup
    super
  end

  def self.before_suite
    super
    @@sys = CandlepinConsumerSupport.create_system('GlueCandlepinConsumerTestSystem_1', @@dev, @@dev_cv)
  end

  def setup
    @@sys.facts['memory.memtotal'] = '256 MB'
    @@sys.facts.delete 'dmi.memory.size'
    @@sys.facts['cpu.cpu_socket(s)'] = '2'
    @@sys.facts['uname.machine'] = 'x86_64'
  end

  # Socket values
  def test_sockets_candlepin_consumer
    assert_equal 2, @@sys.sockets

    @@sys.sockets = '1'
    assert_equal 1, @@sys.sockets

    @@sys.sockets = 1.1
    assert_equal 1, @@sys.sockets

    @@sys.sockets = 1
    assert_equal 1, @@sys.sockets

    @@sys.sockets = 'abc'
    assert_equal 0, @@sys.sockets
  end

  # Memory values
  def test_memory_candlepin_consumer
    assert_equal (256.0 / 1024.0), @@sys.memory

    @@sys.facts['memory.memtotal'] = '2 GB'
    @@sys.facts['dmi.memory.size'] = '4 GB'
    assert_equal 2, @@sys.memory
    @@sys.facts['memory.memtotal'] = nil
    assert_equal 4, @@sys.memory

    @@sys.memory = 'abc'
    assert_equal 0, @@sys.memory
    @@sys.facts['memory.memtotal'] = 3145728 # 3MB
    assert_equal 3, @@sys.memory
  end

  def test_candlepin_system_export
    assert true
    #  assert @dist.export
  end
end

class GlueCandlepinConsumerTestDistributor < GlueCandlepinConsumerTestBase

  def self.before_suite
    super
    @@dist = CandlepinConsumerSupport.create_distributor('GlueCandlepinConsumerTestDistributor_1', @@dev, @@dev_cv)
  end

  def test_candlepin_distributor_export
    skip "Not ready to test"
    assert true
    #  assert @@dist.export
  end

end
end
