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

require 'spec_helper.rb'
include OrchestrationHelper
include SystemHelperMethods

describe Api::V1::OrganizationDefaultInfoController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods

  let(:facts) { { "distribution.name" => "Fedora" } }
  let(:uuid) { '1234' }

  before (:each) do
    login_user
    set_default_locale
    disable_org_orchestration
    disable_consumer_group_orchestration
    disable_system_orchestration

    Resources::Candlepin::Consumer.stub!(:create).and_return({ :uuid => uuid, :owner => { :key => uuid } })

    Runcible::Extensions::Consumer.stub!(:create).and_return({ :id => uuid }) if Katello.config.app_mode == "katello"

    @org  = Organization.create!(:name => "test_org", :label => "test_org")
    @env1 = KTEnvironment.create!(:name => "test_env", :label => "test_env", :prior => @org.library.id, :organization => @org)

    CustomInfo.skip_callback(:save, :after, :reindex_informable)
    CustomInfo.skip_callback(:destroy, :after, :reindex_informable)
  end

  describe "add default custom info to an org" do

    it "should be successful" do
      Organization.find(@org.id).default_info["system"].empty?.should == true
      post :create, :organization_id => @org.label, :keyname => "test_key", :informable_type => "system"
      response.code.should == "200"
      Organization.find(@org.id).default_info["system"].include?("test_key").should == true
    end

    it "should fail without keyname" do
      Organization.find(@org.id).default_info["system"].empty?.should == true
      post :create, :organization_id => @org.label, :informable_type => "system"
      response.code.should == "422"
      Organization.find(@org.id).default_info["system"].empty?.should == true
    end

    it "should fail with wrong org id" do
      Organization.find(@org.id).default_info["system"].empty?.should == true
      post :create, :organization_id => "blahblahblah", :keyname => "test_key", :informable_type => "system"
      response.code.should == "404"
      Organization.find(@org.id).default_info["system"].empty?.should == true
    end

    it "should throw an error when you add default info that is already there" do
      Organization.find(@org.id).default_info["system"].empty?.should == true
      post :create, :organization_id => @org.label, :keyname => "test_key", :informable_type => "system"
      response.code.should == "200"
      Organization.find(@org.id).default_info["system"].size.should == 1

      post :create, :organization_id => @org.label, :keyname => "test_key", :informable_type => "system"
      response.code.should == "400"
      Organization.find(@org.id).default_info["system"].size.should == 1
    end

    it "should fail if the type given is not an accepted type" do
      Organization.find(@org.id).default_info["system"].empty?.should == true
      post :create, :organization_id => "blahblahblah", :keyname => "test_key", :informable_type => "nonstandardtype"
      response.code.should == "404"
      Organization.find(@org.id).default_info["system"].empty?.should == true
    end

  end

  describe "remove default custom info to an org" do

    before (:each) do
      @org.default_info["system"] << "test_key"
      @org.save!
    end

    it "should be successful" do
      Organization.find(@org.id).default_info["system"].size.should == 1
      post :destroy, :organization_id => @org.label, :keyname => "test_key", :informable_type => "system"
      response.code.should == "200"
      Organization.find(@org.id).default_info["system"].empty?.should == true
    end

    it "should fail with wrong org id" do
      Organization.find(@org.id).default_info["system"].size.should == 1
      post :destroy, :organization_id => "bad org label", :keyname => "test_key", :informable_type => "system"
      response.code.should == "404"
      Organization.find(@org.id).default_info["system"].size.should == 1
    end

    it "should raise error with a bad keyname" do
      Organization.find(@org.id).default_info["system"].include?("bad_keyname").should be_false
      post :destroy, :organization_id => @org.label, :keyname => "bad_keyname", :informable_type => "system"
      response.code.should == "404"
    end

  end

  describe "apply default custom info to an org's existing systems" do

    before(:each) do
      (1..50).each do |i|
        System.create!(:name => "test_sys#{i}", :cp_type => "system", :environment => @env1, :facts => facts)
      end
    end

    it "should be successful" do
      @org.systems.each do |s|
        s.custom_info.empty?.should == true
      end
      @org.default_info["system"] << "test_key"
      @org.save!

      get :apply_to_all, :organization_id => @org.label, :informable_type => "system", :async => false
      response.code.should == "200"
      JSON.parse(response.body)["informables"].should_not be_nil
      JSON.parse(response.body)["task"].should be_nil

      @org.systems.each do |s|
        s.custom_info.size.should == @org.default_info["system"].size
      end
    end

    it "should kick off a task when running asynchronously" do
      @org.systems.each do |s|
        s.custom_info.empty?.should == true
      end
      @org.default_info["system"] << "test_key"
      @org.save!

      get :apply_to_all, :organization_id => @org.label, :informable_type => "system", :async => true
      response.code.should == "200"
      JSON.parse(response.body)["informables"].should be_empty
      JSON.parse(response.body)["task"].should_not be_nil
    end
  end
end
