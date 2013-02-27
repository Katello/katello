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
require './test/support/candlepin/consumer_support'
require './test/support/user_support'


class GlueCandlepinConsumerTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend  ActiveRecord::TestFixtures

  fixtures :all

  def self.before_suite
    load_fixtures
    # TODO: RAILS32 remove top reference to load_fixtures
    if @loaded_fixtures.nil?
      @loaded_fixtures = load_fixtures
    end

    services  = ['Pulp', 'ElasticSearch', 'Foreman']
    models    = ['System', 'User', 'KTEnvironment', 'Organization', 'Product', 'ContentView', 'ContentViewDefinition', 'ContentViewEnvironment', 'ContentViewVersion']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    VCR.insert_cassette('glue_candlepin_consumer', :match_requests_on => [:path, :params, :method, :body_json])

    @@dev      = KTEnvironment.find(@loaded_fixtures['environments']['candlepin_dev']['id'])
    @@org      = Organization.find(@loaded_fixtures['organizations']['candlepin_org']['id'])
    @@dev_cv   = ContentView.find(@loaded_fixtures['content_views']['candlepin_library_dev_cv']['id'])
    @@dev_cve  = ContentViewEnvironment.find(@loaded_fixtures['content_view_environments']['candlepin_library_dev_cve']['id'])
    @@dev_cve.cp_id = @@dev_cv.cp_environment_id @@dev

    # Create the environment in candlepin
    @@org.set_owner
    @@dev_cve.set_environment
  end

  def self.after_suite
    @@dev_cve.del_environment
    @@org.del_owner

    VCR.eject_cassette
  end

end

class GlueCandlepinConsumerTestSystem < GlueCandlepinConsumerTestBase

  def self.before_suite
    super
    @@sys = CandlepinConsumerSupport.create_system('GlueCandlepinConsumerTestSystem_1', @@dev, @@dev_cv)
  end

  def self.after_suite
    CandlepinConsumerSupport.destroy_system(@@sys.id)
    super
  end

  def setup
    @@sys.facts['memory.memtotal'] = '256 MB'
    @@sys.facts.delete 'dmi.memory.size'
    @@sys.facts['cpu.cpu_socket(s)'] = '2'
    @@sys.facts['uname.machine'] = 'x86_64'
  end

  def test_update_candlepin_system
    assert_equal 'x86_64', @@sys.arch
    @@sys.arch = 'i686'
    @@sys.update_candlepin_consumer
    assert_equal 'i686', @@sys.arch
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
    assert_equal 256, @@sys.memory

    @@sys.facts['memory.memtotal'] = '2 GB'
    @@sys.facts['dmi.memory.size'] = '4 GB'
    assert_equal 2048, @@sys.memory
    @@sys.facts['memory.memtotal'] = nil
    assert_equal 4096, @@sys.memory

    @@sys.memory = 'abc'
    assert_equal 0, @@sys.memory
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

  def self.after_suite
    CandlepinConsumerSupport.destroy_distributor(@@dist.id)
    super
  end

  def test_candlepin_distributor_update
    assert_equal({}, @@dist.facts)
    @@dist.facts = {:some => 'fact'}
    @@dist.update_candlepin_consumer
    assert_equal({:some => 'fact'}, @@dist.facts)
  end

  def test_candlepin_distributor_export
    skip "Not ready to test"
    assert true
    #  assert @@dist.export
  end

end

class GlueCandlepinConsumerTestSecondDelete < GlueCandlepinConsumerTestBase

  def test_candlepin_system_second_delete
    @sys = CandlepinConsumerSupport.create_system('GlueCandlepinConsumerTestSecondDelete_1', @@dev, @@dev_cv)
    # First delete
    CandlepinConsumerSupport.destroy_system(@sys.id)
    # Second delete
    assert_raises(RestClient::Gone) do
      CandlepinConsumerSupport.destroy_system(@sys.id, 'support/candlepin/system_delete')
    end
  end

  def test_candlepin_distributor_second_delete
    @dist = CandlepinConsumerSupport.create_distributor('GlueCandlepinConsumerTestSecondDelete_2', @@dev, @@dev_cv)
    # First delete
    CandlepinConsumerSupport.destroy_distributor(@dist.id)
    # Second delete
    assert_raises(RestClient::Gone) do
      CandlepinConsumerSupport.destroy_distributor(@dist.id, 'support/candlepin/distributor_delete')
    end
  end

end
