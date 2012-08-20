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

require 'rubygems'
require 'minitest/autorun'
require 'test/integration/pulp/vcr_pulp_setup'


class TestPulpRoles < MiniTest::Unit::TestCase
  def setup
    @username = "integration_test_user"
    @role_name = "super-users"
    @resource = Resources::Pulp::Roles
    VCR.use_cassette('pulp_user') do
      Resources::Pulp::User.create(:login => @username, :name => @username, :password => "integration_test_password")
    end
    VCR.insert_cassette('pulp_roles')
  end

  def teardown
    @resource.remove(@role_name, @username)
    VCR.use_cassette('pulp_user') do
      Resources::Pulp::User.destroy("integration_test_user")
    end
    VCR.eject_cassette
  end

  def test_path_without_role_name
    path = @resource.path
    assert_match("/api/roles/", path)
  end

  def test_path_with_role_name
    path = @resource.path(@role_name)
    assert_match("/api/roles/" + @role_name, path)
  end

  def test_add
    response = @resource.add(@role_name, @username)
    assert response
  end

  def test_remove
    @resource.add(@role_name, @username)
    response = @resource.remove(@role_name, @username)
    assert response
  end

end
