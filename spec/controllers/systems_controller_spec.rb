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

describe SystemsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods

  before (:each) do
    login_user
    set_default_locale
    setup_system_creation
    
    controller.stub!(:errors)
    controller.stub!(:notice)
  end
  
  describe "viewing systems" do
    before (:each) do
      100.times{|a| System.create!(:name=>"bar#{a}", :cp_type=>"system", :facts=>{"Test" => ""})}
    end

    it "should show the system 2 pane list" do
      get :index
      response.should be_success
      response.should render_template("index")
      assigns[:systems].should include System.find(8)
      assigns[:systems].should_not include System.find(30)
    end

    it "should return a portion of systems" do
      get :items, :offset=>25
      response.should be_success
      response.should render_template("list_systems")
      assigns[:systems].should include System.find(30)
      assigns[:systems].should_not include System.find(8)
    end
    
    it "should throw an exception when the search parameters are invalid" do
      controller.should_receive(:errors)
      get :index, :search => 1
      response.should_not be_success
    end
    
    describe 'and requesting individual data' do
      before (:each) do 
        @system = System.create!(:name=>"verbose", :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})
        Pulp::Consumer.stub!(:installed_packages).and_return([])
      end
      
      it "it should show facts" do
        get :facts, :id => @system.id
        response.should be_success
        response.should render_template("facts")
      end
      
      it "should show subscriptions" do
        get :subscriptions, :id => @system.id
        response.should be_success
        response.should render_template("subscriptions")
      end
      
      it "should show packages" do
        get :packages, :id => @system.id
        response.should be_success
        response.should render_template("packages")
      end
    end
  end
  
  describe 'updating a system' do
    before (:each) do
      @system = System.create!(:name=>"bar", :cp_type=>"system", :facts=>{"Test" => ""})
    end
    
    it "should update the system name" do
      put :update, { :id => 1, :system => { :name=> "foo" }}
      response.should be_success
      assigns[:system].name.should == "foo"
    end
    
    it "should update a subscription" do
      put :update_subscriptions, { :id => 1, :system => { :name=> "foo" }}
      response.should be_success
    end
    
    it "should throw an error with bad parameters" do
      put :update, { :id => 1, :system => { :name=> 1 }}
      response.should_not be_success
      System.where(:name=>1).should be_empty
    end
  end

  

end
