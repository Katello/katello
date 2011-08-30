#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'

describe SystemTemplatesController do

  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods



  before(:each) do
    set_default_locale
    login_user

    @organization = new_test_org

    @system_template_1 = SystemTemplate.create!(:name => 'template1', :environment => @organization.locker)
    @system_template_2 = SystemTemplate.create!(:name => 'template2', :environment => @organization.locker)

  end

  describe "GET index" do

    it "requests system template using search criteria" do
      SystemTemplate.should_receive(:search_for) {SystemTemplate}
      SystemTemplate.stub_chain(:where, :limit)
      get :index
    end


    it "returns system templates" do
      controller.should_receive(:retain_search_history)
      get :index
      assigns[:templates].should include @system_template_1
      response.should render_template(:index)
      response.should be_success
    end

  end

  describe "GET show" do
    describe "with valid template id" do
      it "renders a list update partial for 2 pane" do
        get :show, :id => @system_template_1.id
        response.should render_template(:partial => "common/_list_update")
        response.should be_success
      end


    end

    describe "with invalid template id" do
      it "should generate an error notice" do
        controller.should_receive(:errors)
        get :show, :id => 9999
        response.should_not be_success
      end
    end
  end

  describe "GET new" do
    it "instantiates a new key" do
      SystemTemplate.should_receive(:new)
      get :new
      response.should render_template(:partial => "_new")
      response.should be_success
    end
  end

  describe "GET edit" do
    describe "with valid templateid" do
      it "renders an edit partial for 2 pane" do
        get :edit, :id => @system_template_1.id
        response.should render_template(:partial => "_edit")
        response.should be_success

      end

    end

    describe "with invalid template id" do
      it "should generate an error notice" do
        controller.should_receive(:errors)
        get :edit, :id => 9999
        response.should_not be_success
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created activation_key" do
        params = {:name=>"TestTemplate", :description=>"TestDesc"}
        controller.should_receive(:notice)
        post :create, :system_template=>{:name=>params[:name], :description=>params[:description]}
        response.should be_success

        assigns[:template].name.should eq(params[:name])
        assigns[:template].description.should eq(params[:description])
        response.should render_template(:partial => "common/_list_item")
      end

    end

    describe "with invalid params" do
      it "should generate an error notice" do
        controller.should_receive(:errors)
        post :create, :template => {}
        response.should_not be_success
      end
    end
  end

  describe "PUT update" do


    describe "with valid template id" do
      describe "with valid params" do
        it "should update requested field - name" do
          controller.should_receive(:notice)
          put :update, :id => @system_template_1.id, :system_template=>{:name=>"bar"}
          assigns[:template].name.should eq("bar")
          response.should_not redirect_to()
          response.should be_success
        end

        it "should update requested field - description" do
          put :update, :id => @system_template_1.id, :system_template=>{:description=>"bar"}
          assigns[:template].description.should eq("bar")
          response.should be_success
        end

      end

      describe "with invalid params" do
        it "should generate an error notice" do
          controller.should_receive(:errors)
          put :update, :id => @system_template_1.id, :system_template=>{:name=>""}
          response.should_not be_success
        end
      end
    end

    describe "with invalid template  id" do
      it "should generate an error notice" do
        controller.should_receive(:errors)
        put :update, :id => 9999,  :system_template=>{:description=>"bar"}
        response.should_not be_success
      end
    end
  end

  describe "DELETE destroy" do
    describe "with valid template id" do
      before (:each) do
        controller.stub!(:render).and_return("") #ignore missing list_remove js partial
      end

      it "should delete the template" do
        controller.should_receive(:notice)
        delete :destroy, :id => @system_template_1.id
        SystemTemplate.exists?(@system_template_1.id).should be_false
        response.should be_success
      end
    end

    describe "with invalid template id" do
      it "should generate an error notice" do
        controller.should_receive(:errors)
        delete :destroy, :id => 9999
        response.should_not be_success
      end

    end
  end
end
