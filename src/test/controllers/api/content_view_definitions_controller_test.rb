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

class Api::ContentViewDefinitionsControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment",
             "ContentViewDefinition", "Product", "EnvironmentProduct", "Repository"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    login_user(User.find(users(:admin)))
    Product.any_instance.stubs(:productContent).returns([])
    Product.any_instance.stubs(:multiplier).returns(1)
    Product.any_instance.stubs(:attrs).returns({})
    Product.any_instance.stubs(:sync_state).returns(nil)
    Product.any_instance.stubs(:last_sync).returns(nil)
    Product.any_instance.stubs(:sync_plan).returns(nil)
    @cvd = content_view_definition_bases(:populated_cvd)
  end

  test "should show products in the cvd" do
    get :list_products, :organization_id => @cvd.organization.label,
                        :content_view_definition_id=> @cvd.id
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal((body.collect{|item| item['id']}), @cvd.products.pluck(:cp_id))
  end

  test "should show all products in the cvd " do
    cvd = content_view_definition_bases(:populated_with_repos_and_filters)
    get :list_all_products, :organization_id => cvd.organization.label,
        :content_view_definition_id=> cvd.id
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_includes((body.collect{|item| item['id']}), @cvd.repositories.first.product.cp_id)
  end

  test "should update product to the cvd" do
    refute_empty(@cvd.products)
    post :update_products, :organization_id => @cvd.organization.label,
                    :content_view_definition_id=> @cvd.id,
                    :products => []
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_empty(ContentViewDefinition.find(@cvd.id).products)
  end

  test "should show repos in the cvd" do
    get :list_repositories, :organization_id => @cvd.organization.label,
        :content_view_definition_id=> @cvd.id
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal(@cvd.repositories.collect(&:label), (body.collect{|item| item['label']}))
  end


  test "should update product to the cvd" do
    refute_empty(@cvd.repositories)
    post :update_repositories, :organization_id => @cvd.organization.label,
         :content_view_definition_id=> @cvd.id,
         :repos => []
    assert_response :success
    assert_kind_of Array, JSON.parse(response.body)
    assert_empty(ContentViewDefinition.find(@cvd.id).repositories)
  end

end