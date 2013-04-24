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
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment",
             "ContentViewDefinition", "Product", "EnvironmentProduct", "Repository"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    login_user(User.find(users(:admin)))
    @filter = filters(:simple_filter)
    @cvd = @filter.content_view_definition
    @organization = @cvd.organization
    Product.any_instance.stubs(:productContent).returns([])
    Product.any_instance.stubs(:multiplier).returns(1)
    Product.any_instance.stubs(:attrs).returns({})
    Product.any_instance.stubs(:sync_state).returns(nil)
    Product.any_instance.stubs(:last_sync).returns(nil)
    Product.any_instance.stubs(:sync_plan).returns(nil)

    @readable_permissions =  lambda {|u| u.can(:read, :content_view_definitions, [@cvd.id], @organization)}
    @editable_permissions = lambda {|u| u.can(:update, :content_view_definitions, [@cvd.id] , @organization)}

  end

  test "should return a list of filters" do
    get :index, :organization_id => @organization.label,
                :content_view_definition_id=> @cvd.id
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    refute_empty body
  end

  test "index perms" do
    assert_permission(
        :authorized => @readable_permissions,
        :action => :index,
        :request => lambda { get :index, :organization_id => @organization.label,
                                 :content_view_definition_id => @cvd.id}
    )
  end

  test "should return a filter" do
    get :show, :organization_id => @filter.content_view_definition.organization.label,
                :content_view_definition_id=> @filter.content_view_definition.id,
                :id => @filter.id
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Hash, body
    assert_equal @filter.name, body["name"]
  end

  test "show perms" do
    assert_permission(
        :authorized => @readable_permissions,
        :action => :show,
        :request => lambda {
          get :show, :organization_id => @filter.content_view_definition.organization.label,
              :content_view_definition_id=> @filter.content_view_definition.id,
              :id => @filter.id
        }
    )
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

  test "delete perms" do
    assert_permission(
        :authorized => @editable_permissions,
        :unauthorized => @readable_permissions,
        :action => :destroy,
        :request => lambda do
          delete :destroy, :organization_id => @filter.content_view_definition.organization.label,
                 :content_view_definition_id=> @filter.content_view_definition.id,
                 :id => @filter.id
          end
    )
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

  test "create perms" do
    assert_permission(
        :authorized => @editable_permissions,
        :action => :create,
        :request => lambda {
          name = @filter.name + "Cool"
          post :create, :organization_id => @filter.content_view_definition.organization.label,
               :content_view_definition_id=> @filter.content_view_definition.id,
               :filter => name
        }
    )
  end

  test "should show products in the filter" do
    populated_filter = filters(:populated_filter)
    cvd = populated_filter.content_view_definition
    product = cvd.products.first
    populated_filter.products << product
    populated_filter.save!
    get :list_products, :organization_id => populated_filter.content_view_definition.organization.label,
                        :content_view_definition_id=> populated_filter.content_view_definition.id,
                        :filter_id => populated_filter.id
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_includes((body.collect{|item| item['id']}), product.cp_id )
  end


  test "should add product to the filter" do
    populated_filter = filters(:populated_filter)
    cvd = populated_filter.content_view_definition
    product_id = cvd.products.first.cp_id
    refute_includes(populated_filter.products, product_id)
    post :update_products, :organization_id => populated_filter.content_view_definition.organization.label,
                    :content_view_definition_id=> populated_filter.content_view_definition.id,
                    :filter_id => populated_filter.id, :products => [product_id]
    assert_response :success
    assert_kind_of Array, JSON.parse(response.body)
    assert_includes(Filter.find(populated_filter.id).products.pluck(:cp_id), product_id)
  end

  test "should show repos in the filter" do
    populated_filter = filters(:populated_filter)
    cvd = populated_filter.content_view_definition
    repo = cvd.repositories.first
    populated_filter.repositories << repo
    populated_filter.save!
    get :list_repositories, :organization_id => populated_filter.content_view_definition.organization.label,
        :content_view_definition_id=> populated_filter.content_view_definition.id,
        :filter_id => populated_filter.id
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_includes((body.collect{|item| item['label']}), repo.label)
  end

  test "should add repos to the filter" do
    populated_filter = filters(:populated_filter)
    cvd = populated_filter.content_view_definition
    repo_id = cvd.repositories.first.id
    refute_includes(populated_filter.repositories, repo_id)
    post :update_repositories, :organization_id => populated_filter.content_view_definition.organization.label,
         :content_view_definition_id=> populated_filter.content_view_definition.id,
         :filter_id => populated_filter.id, :repos => [repo_id]
    assert_response :success
    assert_kind_of Array, JSON.parse(response.body)
    assert_includes(Filter.find(populated_filter.id).repositories.collect(&:id), repo_id)
  end

end