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
    login_user(User.find(users(:admin)))

    @edit_permission = UserPermission.new(:edit, :products)
    @read_permission = UserPermission.new(:read, :products)
  end

  def test_create
    mock_pulp_server(:create_upload_request => [])
    post :create, :repository_id => @repo.id
    assert_response :success
  end

  def test_upload_bits
    mock_pulp_server(:upload_bits => true)
    put :upload_bits, :id => "1" , :offset => "0", :content => "/tmp/my_file.rpm",
      :repository_id => @repo.id
    assert_response :success
  end

  def test_destroy
    mock_pulp_server(:delete_upload_request => true)
    delete :destroy, :id => "1", :repository_id => @repo.id
    assert_response :success
  end

  def test_index
    mock_pulp_server(:list_all_requests => [])
    get :index
    assert_response :success
  end

  private

  def mock_pulp_server(content_hash)
    content = mock(content_hash)
    resources = mock(:content => content)
    pulp_server = mock(:resources => resources)
    Katello.expects(:pulp_server).returns(pulp_server)
  end
end
