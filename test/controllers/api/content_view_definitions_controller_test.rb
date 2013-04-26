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

describe Api::ContentViewDefinitionsController do
  fixtures :all

  before do
    models = ["Organization", "KTEnvironment", "User","ContentViewEnvironment",
             "ContentViewDefinition", "Product", "EnvironmentProduct", "Repository"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    login_user(User.find(users(:admin)))
    @organization = Organization.find(organizations(:acme_corporation))
    organization_relation = stub(first: @organization)
    without_deleting = stub(having_name_or_label: organization_relation)
    Organization.stubs(:without_deleting).returns(without_deleting)
  end

  after do
    ContentViewDefinition.delete_all
  end

  describe "index" do
    before do
      @defs = FactoryGirl.create_list(:content_view_definition, 3,
                                      :organization => @organization)
    end

    let(:action) { :index }

    describe "with organization_id" do
      it "should assign the organiation's definitions" do
        get action, :organization_id => @organization.name
        response.must_be :success?
        assigns(:definitions).map(&:id).must_equal ContentViewDefinition.pluck(:id)
      end
    end

    describe "with label" do
      it "should find the matching content view definition" do
        get action, :organization_id => @organization.name,
          :label => @defs.last.label
        assigns(:definitions).map(&:id).must_equal [@defs.last.id]
      end
    end

    describe "with id" do
      it "should find the matching definition" do
        cvd = @defs.sample
        get action, :organization_id => @organization.name,
          :id => cvd.id
        assigns(:definitions).map(&:id).must_equal [cvd.id]
      end
    end

    describe "with name" do
      it "should find the matching definitions" do
        view = ContentViewDefinition.last
        get action, :organization_id => @organization.name, :name => view.name
        assigns(:definitions).length.must_equal 1
        assigns(:definitions).map(&:id).must_equal [view.id]
      end
    end
  end

  describe "publish" do
    before do
      FactoryGirl.create_list(:content_view_definition, 2, :organization => @organization)
    end
    let(:definition) { @organization.content_view_definitions.last }

    it "should create a content view" do
      cv_count = ContentView.count
      req = post :publish, :id => definition.id,
        :organization_id => @organization.id, :name => "TestView"
      response.must_be :success?
      ContentView.count.must_equal(cv_count + 1)
    end
  end

  describe "create" do
    it "should create a composite definition if composite is supplied" do
      post :create, content_view_definition: {name: "Test", composite: 1},
        organization_id: @organization.id
      response.must_be :success?
      ContentViewDefinition.last.must_be :composite
    end
  end

  describe "destroy" do
    it "should delete the definition after checking it has no promoted views" do
      definition = FactoryGirl.build_stubbed(:content_view_definition)
      ContentViewDefinition.stubs(:find).with(definition.id.to_s).returns(definition)
      definition.expects(:destroy).returns(true)
      definition.expects(:has_promoted_views?).returns(false)
      delete :destroy, :id => definition.id.to_s

      response.must_be :success?
    end
  end

  describe "update" do
    it "should not allow me to change the definition's org" do
      org1 = FactoryGirl.create(:organization)
      org2 = FactoryGirl.create(:organization)
      content_view_definition = FactoryGirl.create(:content_view_definition,
                                                   :organization => org1
                                                  )
      put :update, :id => content_view_definition.id, :organization_id => org1.id,
        :content_view_definition => {:organization_id => org2.id}
      content_view_definition.reload.organization_id.wont_equal org2.id
    end
  end

  describe "update_content_views" do
    it "should update the definition's components" do
      definition = FactoryGirl.create(:content_view_definition, :composite => true)
      views = FactoryGirl.create_list(:content_view, 2)
      relation = stub(where: views)
      ContentView.stubs(:readable).returns(relation)

      put :update_content_views, :id => definition.id, :views => views.map(&:id)
      response.must_be :success?
      definition.component_content_views.reload.length.must_equal 2
    end
  end

  describe "product actions" do
    before do
      Product.any_instance.stubs(:productContent).returns([])
      Product.any_instance.stubs(:multiplier).returns(1)
      Product.any_instance.stubs(:attrs).returns({})
      Product.any_instance.stubs(:sync_state).returns(nil)
      Product.any_instance.stubs(:last_sync).returns(nil)
      Product.any_instance.stubs(:sync_plan).returns(nil)
      @cvd = content_view_definition_bases(:populated_cvd)
    end

    describe "list_products" do
      it "should show products in the cvd" do
        get :list_products, :organization_id => @cvd.organization.label,
                            :content_view_definition_id=> @cvd.id
        assert_response :success

        body = JSON.parse(response.body)
        assert_kind_of Array, body
        assert_equal((body.collect{|item| item['id']}), @cvd.products.pluck(:cp_id))
      end
    end

    describe "list_all_products" do
      it "should show all products in the cvd " do
        cvd = content_view_definition_bases(:populated_with_repos_and_filters)
        get :list_all_products, :organization_id => cvd.organization.label,
            :content_view_definition_id=> cvd.id
        assert_response :success

        body = JSON.parse(response.body)
        assert_kind_of Array, body
        assert_includes((body.collect{|item| item['id']}), @cvd.repositories.first.product.cp_id)
      end
    end

    describe "update_products" do
      it "should update product to the cvd" do
        refute_empty(@cvd.products)
        post :update_products, :organization_id => @cvd.organization.label,
                        :content_view_definition_id=> @cvd.id,
                        :products => []
        assert_response :success

        body = JSON.parse(response.body)
        assert_kind_of Array, body
        assert_empty(ContentViewDefinition.find(@cvd.id).products)
      end
    end

    describe "list_repositories" do
      it "should show repos in the cvd" do
        get :list_repositories, :organization_id => @cvd.organization.label,
            :content_view_definition_id=> @cvd.id
        assert_response :success

        body = JSON.parse(response.body)
        assert_kind_of Array, body
        assert_equal(@cvd.repositories.collect(&:label), (body.collect{|item| item['label']}))
      end
    end

    describe "update_repostories" do
      it "should update product to the cvd" do
        refute_empty(@cvd.repositories)
        post :update_repositories, :organization_id => @cvd.organization.label,
             :content_view_definition_id=> @cvd.id,
             :repos => []
        assert_response :success
        assert_kind_of Array, JSON.parse(response.body)
        assert_empty(ContentViewDefinition.find(@cvd.id).repositories)
      end
    end

  end # product/repository actions

end