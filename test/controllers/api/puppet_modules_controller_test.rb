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

require "minitest_helper"

class Api::V1::PuppetModulesControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def before_suite
    models = ["Organization", "KTEnvironment", "PuppetModule", "Repository", "Product", "Provider"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
  end

  def setup
    @repo = Repository.find(repositories(:p_forge))
    @env_read_permission = UserPermission.new(:read_contents, :environments)
    @prod_read_permission = UserPermission.new(:read, :providers)
    @read_permission = @env_read_permission + @prod_read_permission
    @unauth_perms = [NO_PERMISSION, @env_read_permission, @prod_read_permission]
    login_user(User.find(users(:admin)))
  end

  def test_index
    action = :index

    assert_protected_action(action, @read_permission, @unauth_perms) do
      get action, :repository_id => @repo.id
    end
  end

  def test_search
    action = :search

    assert_protected_action(action, @read_permission, @unauth_perms) do
      get action, :repository_id => @repo.id
    end
  end

  def test_show
    action = :show
    PuppetModule.expects(:find).once.returns(mock({:repoids => [@repo.pulp_id]}))

    assert_protected_action(action, @read_permission, @unauth_perms) do
      get action, :repository_id => @repo.id, :id => "abc-123"
    end
  end

  def test_find_puppet_module
    PuppetModule.expects(:find).once.returns(mock({:repoids => ['uh-oh']}))
    get :show, :repository_id => @repo.id, :id => "abc-123"
    assert_response 404
  end
end
