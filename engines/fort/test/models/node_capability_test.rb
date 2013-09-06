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

require 'support/fake_node_capability'

class NodeCapabilityTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures
  fixtures :all

  def setup
    @system = System.find(systems(:simple_server))
    @dev    = KTEnvironment.find(environments(:dev).id)
    @node = Node.create!(:system => @system)
  end
end

class NodeCapabilityCreateTest < NodeCapabilityTestBase

  def test_create
    capability = FakeNodeCapability.create!(:node=>@node, :configuration=>{:foo=>:bar})
    assert capability
  end

end

class NodeCapabilityExistingTest < NodeCapabilityTestBase

  def setup
    super
    @capability = FakeNodeCapability.create!(:node=>@node)
    @node.reload #reload to pickup capability
  end

  def test_destroy
    assert @capability.destroy
  end

  def test_update
    @capability.update_attributes!(:configuration=>{"foo"=>"baz"})
    assert_equal "baz", NodeCapability.find(@capability.id).configuration["foo"]
  end

  def test_node_add_env
    FakeNodeCapability.any_instance.expects(:update_environments)
    @node.environments << @dev
    @node.save!
  end

  def test_node_sync
    FakeNodeCapability.any_instance.expects(:sync)
    @node.sync
  end

end
