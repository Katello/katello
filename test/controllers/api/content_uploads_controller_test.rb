# encoding: utf-8
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

class Api::V1::ContentUploadsControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def before_suite
    models = ["Organization", "KTEnvironment", "Repository", "Product", "Provider"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
  end

  def setup
    @repo = Repository.find(repositories(:fedora_17_x86_64))
    @org = organizations(:acme_corporation)
    @environment = environments(:library)
    @env_read_permission = UserPermission.new(:read_contents, :environments)
    @prod_read_permission = UserPermission.new(:read, :providers)
    @read_permission = @env_read_permission + @prod_read_permission
    @unauth_perms = [NO_PERMISSION, @env_read_permission, @prod_read_permission]
    login_user(User.find(users(:admin)))
  end

  def test_create
    action = :create

    assert_protected_action(action, @read_permission, @unauth_perms) do
      get action
    end
  end

  def test_upload
    action = :upload_bits

    assert_protected_action(action, @read_permission, @unauth_perms) do
      get action, :id => "1" , :offset => "0", :content => "/tmp/my_file.rpm"
    end
  end

  def test_delete
    action = :destroy

    assert_protected_action(action, @read_permission, @unauth_perms) do
      get action, :id => "1"
    end
  end

  def test_list
    action = :index

    assert_protected_action(action, @read_permission, @unauth_perms) do
      get action
    end
  end

end
