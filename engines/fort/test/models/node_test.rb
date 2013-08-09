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

class NodeTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures
  fixtures :all

  def self.before_suite
    configure_runcible
    User.current = User.find(load_fixtures['users']['admin']['id'])
    VCR.insert_cassette('node', :match_requests_on => [:path, :params, :method, :body_json])
  end

  def self.after_suite
    VCR.eject_cassette
  end
end


class NodeTest < NodeTestBase

  def setup
    @system = System.find(systems(:simple_server))
    @dev    = KTEnvironment.find(environments(:dev).id)
  end

  def test_create
    node = Node.create!(:system => @system)
    assert node
  end

  def test_destroy
    node = Node.create!(:system => @system)
    node_id = node.id
    assert node.destroy
    assert_empty Node.where(:id => node_id)
  end

  def test_add_environment
    node = Node.create!(:system => @system)
    node.environments << @dev
    node.save!

    node = Node.find(node.id)
    assert_equal 1, Node.find(node).environments.size
  end

  def test_remove_environment
    node = Node.create!(:system => @system, :environment_ids => [@dev.id])
    node.environments.delete(@dev)
    node.save!

    node = Node.find(node.id)
    assert_empty Node.find(node).environments
  end

end


class NodeSystemDeleteTest < NodeTestBase

  def setup
    @system = System.find(systems(:simple_server))
    @system.set_pulp_consumer
    @system.stubs(:set_candlepin_consumer).returns(true)
    @system.stubs(:del_candlepin_consumer).returns(true)
  end

  def test_system_destroy
    node = Node.create!(:system => @system)
    assert @system.destroy
    assert_empty Node.where(:id=>node.id)
  end
end