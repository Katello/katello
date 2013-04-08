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

class Api::ContentViewsControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    @content_view = content_views(:library_dev_view)
    @environment = environments(:staging)
    @dev = environments(:dev)
    login_user(users(:admin))
    models = ["Organization", "KTEnvironment", "Changeset"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
  end

  test "should throw an error if environment_id is nil" do
    post :promote, :id => @content_view.id
    assert_response :missing
  end

  test "should throw an error if id is nil" do
    assert_raises(ActionController::RoutingError) do
      post :promote, :environment_id => @environment.id
    end
  end

  test "should assign a content view" do
    post :promote, :id => @content_view.id, :environment_id => @environment.id
    assert_response :success
    content_view = assigns(:view)
    refute_nil content_view
    assert_equal @content_view, content_view
  end

  test "should create a new changeset" do
    changeset_count = Changeset.count
    post :promote, :id => @content_view.id, :environment_id => @environment.id
    assert_equal (changeset_count + 1), Changeset.count
  end

end
