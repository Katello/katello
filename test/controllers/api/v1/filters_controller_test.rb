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
require './test/support/content_view_definition_support'

describe Api::V1::FiltersController do
  fixtures :all
  before :suite do
    models = ["User", "Role", "UserOwnRole", "Permission", "Organization", "KTEnvironment",
              "Filter", "ContentViewDefinition",
              "Product", "Repository"]

    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  before do
    login_user(User.find(users(:admin)))
    @filter = filters(:simple_filter)
    Product.any_instance.stubs(:productContent).returns([])
    Product.any_instance.stubs(:multiplier).returns(1)
    Product.any_instance.stubs(:attrs).returns({})
    Product.any_instance.stubs(:sync_state).returns(nil)
    Product.any_instance.stubs(:last_sync).returns(nil)
    Product.any_instance.stubs(:sync_plan).returns(nil)
    @cvd = @filter.content_view_definition
    @organization = @cvd.organization

    perms = ContentViewDefinitionSupport.generate_permissions(@cvd, @organization)
    @readable_permissions = perms.readable
    @edit_permissions = perms.editable
    @read_only_permissions = perms.read_only
  end

  describe "index" do
    before do
      @req = lambda do
        get :index, :organization_id => @organization.label,
            :content_view_definition_id => @cvd.id
      end
    end
    it "permissions" do
      action = :index

      assert_authorized(
          :permission => @readable_permissions ,
          :action => :index,
          :request => @req
      )
      refute_authorized(:action => action,
                        :request => @req)
    end

    it "should return a list of filters" do
      @req.call
      assert_response :success
      body = JSON.parse(response.body)
      assert_kind_of Array, body
      refute_empty body
    end
  end

  describe "show" do
    before do
      @req = lambda do
        get :show, :organization_id => @filter.content_view_definition.organization.label,
            :content_view_definition_id=> @filter.content_view_definition.id,
            :id => @filter.id
      end
    end

    it "permissions" do
      action = :show
      assert_authorized(
          :permission => @readable_permissions,
          :action => action,
          :request => @req
      )

      refute_authorized(:action => action,
                        :request => @req)
    end

    it "should return a filter" do
      @req.call
      assert_response :success

      body = JSON.parse(response.body)
      assert_kind_of Hash, body
      assert_equal @filter.name, body["name"]
    end

    it "should throw an 404 if definition is not found" do
      get :show, :organization_id => @filter.content_view_definition.organization.label,
          :content_view_definition_id=> rand(100),
          :id => @filter.id
      assert_response :missing
    end

    it "should throw an 404 if filter is not found" do
      get :show, :organization_id => @filter.content_view_definition.organization.label,
          :content_view_definition_id=> @filter.content_view_definition.id,
          :id => -1
      assert_response :missing
    end

  end

  describe "delete" do
    before do
      @req = lambda do
        delete :destroy, :organization_id => @filter.content_view_definition.organization.label,
               :content_view_definition_id=> @filter.content_view_definition.id,
               :id => @filter.id
      end
    end
    it "permissions" do
      action = :destroy

      assert_authorized(:permission => @edit_permissions,
                        :action => action,
                        :request => @req)

      refute_authorized(:permission => [*@read_only_permissions, NO_PERMISSION],
                        :action => action,
                        :request => @req
      )
    end

    it "should delete a filter" do
      @req.call
      assert_response :success
      assert_nil Filter.find_by_name(@filter.name)
    end


  end

  describe "create" do
    before do
      @name = @filter.name + "Cool"
      @req = lambda do
        post :create, :organization_id => @filter.content_view_definition.organization.label,
             :content_view_definition_id=> @filter.content_view_definition.id,
             :filter => @name
      end
    end
    it "create permissions" do
      action = :create
      assert_authorized(
          :permission => @edit_permissions,
          :action => action,
          :request => @req
      )

      refute_authorized(:permission => [*@read_only_permissions, NO_PERMISSION],
                        :action => action,
                        :request => @req
      )
    end

    it "should create a filter" do
      @req.call
      assert_response :success
      assert_kind_of Hash, JSON.parse(response.body)
      assert_equal @name, JSON.parse(response.body)["name"]
      refute_nil Filter.find_by_name(@name)
    end
  end



  describe "list_products" do
    before do
      @filter = filters(:populated_filter)
      @cvd = @filter.content_view_definition
      @organization = @cvd.organization
      @product = @cvd.products.first
      @filter.products << @product
      @filter.save!

      @req = lambda do
        get :list_products, :organization_id => @organization.label,
            :content_view_definition_id=> @cvd.id,
            :filter_id => @filter.id
      end

    end
    it "permission" do
      action = :list_products
      perms = ContentViewDefinitionSupport.generate_permissions(@cvd, @organization)
      assert_authorized(
          :permission => perms.readable,
          :action => action,
          :request => @req
      )

      refute_authorized(:action => action,
                        :request => @req)
    end

    it "show" do
      @req.call
      assert_response :success

      body = JSON.parse(response.body)
      assert_kind_of Array, body
      assert_includes((body.collect{|item| item['id']}), @product.cp_id )
    end

  end


  describe "update_products" do
    before do
      @filter = filters(:populated_filter)
      @cvd = @filter.content_view_definition
      @organization = @cvd.organization
      @product_id = @cvd.products.first.cp_id
      refute_includes(@filter.products, @product_id)
      @req = lambda do
        post :update_products, :organization_id => @organization.label,
             :content_view_definition_id=> @cvd.id,
             :filter_id => @filter.id, :products => [@product_id]
      end

    end

    it "update" do
      action = :update_products
      perms = ContentViewDefinitionSupport.generate_permissions(@cvd, @organization)
      assert_authorized(
          :permission => perms.editable,
          :action => action,
          :request => @req
      )

      refute_authorized(:permission => [*perms.read_only, NO_PERMISSION],
                        :action => action,
                        :request => @req,
      )
    end


    it "should add product to the filter" do
      @req.call
      assert_response :success
      assert_kind_of Array, JSON.parse(response.body)
      assert_includes(Filter.find(@filter.id).products.pluck(:cp_id), @product_id)
    end

  end

  describe "list_repositories" do
    before do
      @filter = filters(:populated_filter)
      @cvd = @filter.content_view_definition
      @organization = @cvd.organization
      @repo = @cvd.repositories.first
      @filter.repositories << @repo
      @filter.save!

      @req = lambda do
        get :list_repositories, :organization_id =>@organization.label,
            :content_view_definition_id=> @cvd.id,
            :filter_id => @filter.id
      end

    end
    it "permission" do
      action = :list_repositories
      perms = ContentViewDefinitionSupport.generate_permissions(@cvd, @organization)
      assert_authorized(
          :permission => perms.readable,
          :action => action,
          :request => @req
      )

      refute_authorized(:action => action,
                        :request => @req
      )
    end

    it "show" do
      @req.call
      assert_response :success
      body = JSON.parse(response.body)
      assert_kind_of Array, body
      assert_includes((body.collect{|item| item['label']}), @repo.label)
    end
  end

  describe "update_repositories" do
    before do
      @filter = filters(:populated_filter)
      @cvd = @filter.content_view_definition
      @organization = @cvd.organization
      @repo_id = @cvd.repositories.first.id
      refute_includes(@filter.repositories, @repo_id)

      @req = lambda do
        post :update_repositories, :organization_id => @organization.label,
             :content_view_definition_id=> @cvd.id,
             :filter_id => @filter.id, :repos => [@repo_id]
      end

    end

    it "permission" do
      action = :update_repositories
      perms = ContentViewDefinitionSupport.generate_permissions(@cvd, @organization)
      assert_authorized(
          :permission => perms.editable,
          :action => action,
          :request => @req
      )

      refute_authorized(:permission => [*perms.read_only, NO_PERMISSION],
                        :action => action,
                        :request => @req
      )
    end

    it "should add repos to the filter" do
      @req.call
      assert_response :success
      assert_kind_of Array, JSON.parse(response.body)
      assert_includes(Filter.find(@filter.id).repositories.collect(&:id), @repo_id)
    end

  end

end
