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

class Api::FiltersControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment", "ContentViewDefinition"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    login_user(User.find(users(:admin)))
    @filter = filters(:simple_filter)
  end

  test "should return a list of filters" do
    get :index, :organization_id => @filter.content_view_definition.organization.label,
                :content_view_definition_id=> @filter.content_view_definition.id
    assert_response :success
    assert_kind_of Array, JSON.parse(response.body)
    refute_empty JSON.parse(response.body)
  end

  test "should return a filter" do
    get :show, :organization_id => @filter.content_view_definition.organization.label,
                :content_view_definition_id=> @filter.content_view_definition.id,
                :id => @filter.id
    assert_response :success
    assert_kind_of Hash, JSON.parse(response.body)
    assert_equal @filter.name, JSON.parse(response.body)["name"]
  end

  test "should throw an 404 if definition is not found" do
    get :show, :organization_id => @filter.content_view_definition.organization.label,
                :content_view_definition_id=> rand(100),
                :id => @filter.id
    assert_response :missing
  end

  test "should throw an 404 if filter is not found" do
    get :show, :organization_id => @filter.content_view_definition.organization.label,
                :content_view_definition_id=> @filter.content_view_definition.id,
                :id => -1
    assert_response :missing
  end


  test "should delete a filter" do
    delete :destroy, :organization_id => @filter.content_view_definition.organization.label,
                :content_view_definition_id=> @filter.content_view_definition.id,
                :id => @filter.id
    assert_response :success
    assert_nil Filter.find_by_name(@filter.name)
  end

  test "should create a filter" do
    name = @filter.name + "Cool"
    post :create, :organization_id => @filter.content_view_definition.organization.label,
                :content_view_definition_id=> @filter.content_view_definition.id,
                :filter => name
    assert_response :success
    assert_kind_of Hash, JSON.parse(response.body)
    assert_equal name, JSON.parse(response.body)["name"]
    refute_nil Filter.find_by_name(name)
  end

end
