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

describe OrganizationsController do  
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  module OrgControllerTest
    ORG_ID = 1
    ORGANIZATION = {:name => "organization_name", :description => "organization_description", :envdescription=>"foo", :envname => "organization_env"}
    ORGANIZATION_UPDATE = { :description => "organization_description"}
  end

  describe "rules" do
    before (:each) do
      @org1 = new_test_org
      @organization = new_test_org
    end
    describe "GET index" do
      let(:action) {:items}
      let(:req) { get :items }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :organizations,nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end

      let(:before_success) do
        controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
          found = nil
          search_options[:filter].each{|f|  found = f['id'] if f['id'] }
          assert !found.include?(@org1.id)
          assert found.include?(@organization.id)
          controller.stub(:render)
        }
      end

      it_should_behave_like "protected action"
    end

    describe "update org put" do
      before do
        @organization.stub!(:update_attributes!).and_return(OrgControllerTest::ORGANIZATION)
        @organization.stub!(:name).and_return(OrgControllerTest::ORGANIZATION[:name])
        Organization.stub!(:first).and_return(@organization)
      end
      let(:action) {:update}
      let(:req) do
        put 'update', :id => @organization.id, :organization => OrgControllerTest::ORGANIZATION_UPDATE
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :organizations,nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  before (:each) do
    login_user
    set_default_locale
    controller.stub!(:notice)
    controller.stub(:search_validate).and_return(true)
  end
  
  describe "create a root org" do        
    describe 'with valid parameters' do
      before (:each) do
        # for these tests we need full user
        login_user :mock => false

        @organization = new_test_org #controller.current_organization
        controller.stub!(:current_organization).and_return(@organization)
      end

      it 'should create organization' do
        post 'create', OrgControllerTest::ORGANIZATION
        response.should_not redirect_to(:action => 'new')
        response.should be_success
        assigns[:organization].name.should == OrgControllerTest::ORGANIZATION[:name]
      end

      it 'should create organization and account for spaces' do
        post 'create', {:name => "multi word organization", :description => "spaced out organization", :envname => "first-env"}
        response.should_not redirect_to(:action => 'new')
        response.should be_success
        assigns[:organization].name.should == "multi word organization"
        assigns[:organization].cp_key.should == "multi_word_organization"
      end

      it 'should generate a success notice' do
        controller.should_receive(:notice)
        post 'create', OrgControllerTest::ORGANIZATION
        response.should be_success
      end      
    end
    
    describe 'with invalid paramaters' do
      it 'should generate an error notice' do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        post 'create', { :name => "", :description => "" }
        response.should_not be_success
      end

      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:name => "multi word organization", :description => "spaced out organization", :envname => "first-env"}
          bad_req[:bad_foo] = "mwahaha"
          post :create, bad_req
        end
      end
    end
    
  end
  
  describe "get a listing of organizations" do
    before (:each) do
     new_test_org
    end
    
    it 'should call katello organization find api' do
      get :index
      response.should be_success
      response.should render_template("index")
    end

    it 'should allow for an offset' do
      controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, filters|
        start.should == 5
        controller.stub(:render)
      }
      get 'items', :offset=>5
      response.should be_success
    end
  end
  

  describe "delete an organization" do
    
    describe "with no exceptions thrown" do
      before (:each) do
        
        login_user :mock=>false
        @controller.stub!(:render).and_return("") #fix for not finding partial
        @org = new_test_org
        @org.stub!(:name).and_return(OrgControllerTest::ORGANIZATION[:name])
        Organization.stub!(:first).and_return(@org)
        new_test_org
      end

      it 'should call katello organization destroy api if there are more than 1 organizations' do
        @controller.stub(:current_user).and_return(@user)
        Organization.stub!(:count).and_return(2)
        @user.should_receive(:destroy_organization_async).with(@org).once.and_return(true)
        delete 'destroy', :id => @org.id
        response.should be_success
      end

      it "should generate a success notice" do
        Organization.stub!(:count).and_return(2)
        @user.should_receive(:destroy_organization_async).with(@org).once.and_return(true)
        controller.should_receive(:notice)
        delete 'destroy', :id => @org.id
        response.should be_success
      end
      
      it "should be successful" do
        Organization.stub!(:count).and_return(2)
        delete 'destroy', :id => @org.id
        response.should be_success
      end
    end

    describe "with exceptions thrown" do
      before (:each) do
        new_test_org
        Organization.stub!(:first).and_return(@organization)
      end
      it "should generate an errors notice" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        delete 'destroy', :id => @organization.id
        response.should_not be_success
      end
    end

    describe "exception is thrown in katello api" do
      before (:each) do
        @organization = new_test_org
        @organization.stub!(:destroy).and_raise(Exception)
        Organization.stub!(:first).and_return(@organization)
      end
      
      it "should generate an error notice" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        delete 'destroy', :id =>  OrgControllerTest::ORG_ID
        response.should_not be_success
      end
      
      it "should redirect to show view" do
        delete 'destroy', :id =>  OrgControllerTest::ORG_ID
        response.should_not be_success
      end      
    end
  end
  
  describe "update a organization" do
    
    describe "with no exceptions thrown" do

      before (:each) do
        @organization = new_test_org
        @organization.stub!(:update_attributes!).and_return(OrgControllerTest::ORGANIZATION)
        @organization.stub!(:name).and_return(OrgControllerTest::ORGANIZATION[:name])
        Organization.stub!(:first).and_return(@organization)
      end
      
      it "should call katello org update api" do
        @organization.should_receive(:update_attributes!).once
        put 'update', :id => OrgControllerTest::ORG_ID, :organization => OrgControllerTest::ORGANIZATION_UPDATE
        response.should be_success
      end
      
      it "should generate a success notice" do
        controller.should_receive(:notice) 
        put 'update', :id => OrgControllerTest::ORG_ID, :organization => OrgControllerTest::ORGANIZATION_UPDATE
      end
      
      it "should not redirect from edit view" do
        put 'update', :id => OrgControllerTest::ORG_ID, :organization => OrgControllerTest::ORGANIZATION_UPDATE
        response.should_not be_redirect
      end
    end
    describe "with invalid params" do
      before do
        @organization = new_test_org
      end
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:id => @organization.id, :organization => {:description =>"grand" }}
          bad_req[:bad_foo] = "mwahaha"
          put :update, bad_req
        end
      end
    end

    describe "exception is thrown in katello api" do
      before(:each) do
        @organization = new_test_org
        @organization.stub!(:update).and_raise(Exception)
        Organization.stub!(:first).and_return(@organization)
      end
      
      it "should generate an error notice" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        put 'update', :id => OrgControllerTest::ORG_ID
      end
      
      it "should not redirect from edit view" do
        put 'update', :id => OrgControllerTest::ORG_ID
        response.should_not be_redirect
      end
    end
  end

  describe "Debug Certificates related test" do
    before (:each) do
      new_test_org
    end
    it "should download" do
      Candlepin::Owner.should_receive(:get_ueber_cert).once.and_return(:cert => "uber",:key=>"ueber")
      get :download_debug_certificate, :id => @organization.id.to_s
      response.should be_success
    end

  end
end
