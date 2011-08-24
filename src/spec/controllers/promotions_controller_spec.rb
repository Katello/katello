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

describe PromotionsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods
  include ProductHelperMethods

  before (:each) do
    login_user
    set_default_locale
  end

  describe "Getting the promotions page " do

    before (:each) do
      @org = new_test_org
      controller.stub(:current_organization).and_return(@org)
      @env = @org.locker
      
    end

    it "should be successful with locker and no next environment" do
      get 'show', :id=>@env.name

      response.should be_success

      assigns(:environment).should  == @env
      assigns(:next_environment).should == nil
    end

    it "should be successful on the locker and a next environment" do
      @env2 = KPEnvironment.new(:organization=>@org, :locker=>false, :name=>"otherenv", :prior=>@org.locker)
      @env2.save!
      get 'show', :id=>@env.name
      response.should be_success
      assigns(:next_environment).should == @env2
      assigns(:environment).should  == @env
      assigns(:path).should_not be_nil
    end

    it "should be successful on the next environment with no changeset" do
      @env2 = KPEnvironment.new(:organization=>@org, :locker=>false, :name=>"otherenv", :prior=>@org.locker)
      @env2.save!
      get 'show', :id=>@env2.name
      response.should be_success
      assigns(:environment).should == @env2
      assigns(:next_environment).should == nil
    end

  end


  describe "Requesting items of a product" do

    before (:each) do
      @org = new_test_org
      controller.stub(:current_organization).and_return(@org)
      @env = @org.locker
      @product = new_test_product(@org, @env)
      @product.stub(:packages).and_return([])
      Product.stub(:find).and_return(@product)
    end

    it "should be successful when requesting packages" do
      get 'packages', :id=>@env.name, :product_id => @product.id
      response.should be_success
      assigns(:environment).should == @env
      assigns(:packages).size.should == 1
    end

    it "should be successful when requesting errata" do
      get 'errata', :id=>@env.name, :product_id => @product.id
      response.should be_success
      assigns(:environment).should == @env
      assigns(:errata).size.should == 1
    end

    it "should be successful when requesting repos" do
      get 'repos', :id=>@env.name, :product_id => @product.id
      response.should be_success
      assigns(:environment).should == @env
      assigns(:repos).size.should == 1
    end

    it "should be successful when requesting distributions" do
      get 'distributions', :id=>@env.name, :product_id => @product.id
      response.should be_success
      assigns(:environment).should == @env
      assigns(:distributions).size.should == 1
    end
  end


end
