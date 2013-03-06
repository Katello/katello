#
# Copyright 2012 Red Hat, Inc.
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

describe Api::OrganizationSystemInfoKeysController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods

  let(:facts) { {"distribution.name" => "Fedora"} }
  let(:uuid) { '1234' }

  before (:each) do
    login_user
    set_default_locale
    disable_org_orchestration
    disable_consumer_group_orchestration
    disable_system_orchestration

    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})

    Runcible::Extensions::Consumer.stub!(:create).and_return({:id => uuid})

    @org = Organization.create!(:name => "test_org", :label => "test_org")
    @env1 = KTEnvironment.create!(:name => "test_env", :label => "test_env", :prior => @org.library.id, :organization => @org)

    CustomInfo.skip_callback(:save, :after, :reindex_informable)
    CustomInfo.skip_callback(:destroy, :after, :reindex_informable)
  end

  describe "add default custom info to an org" do

    it "should be successful", :katello => true do #TODO headpin
      Organization.find(@org.id).system_info_keys.empty?.should == true
      post :create, :organization_id => @org.label, :keyname => "test_key"
      response.code.should == "200"
      Organization.find(@org.id).system_info_keys.include?("test_key").should == true
    end

    it "should fail without keyname", :katello => true do #TODO headpin
      Organization.find(@org.id).system_info_keys.empty?.should == true
      post :create, :organization_id => @org.label
      response.code.should == "400"
      Organization.find(@org.id).system_info_keys.empty?.should == true
    end

    it "should fail with wrong org id", :katello => true do #TODO headpin
      Organization.find(@org.id).system_info_keys.empty?.should == true
      post :create, :organization_id => "blahblahblah", :keyname => "test_key"
      response.code.should == "404"
      Organization.find(@org.id).system_info_keys.empty?.should == true
    end

  end

  describe "remove default custom info to an org" do

    before (:each) do
      @org.system_info_keys << "test_key"
      @org.save!
    end

    it "should be successful", :katello => true do #TODO headpin
      Organization.find(@org.id).system_info_keys.size.should == 1
      post :destroy, :organization_id => @org.label, :keyname => "test_key"
      response.code.should == "200"
      Organization.find(@org.id).system_info_keys.empty?.should == true
    end

    it "should fail with wrong org id", :katello => true do #TODO headpin
      Organization.find(@org.id).system_info_keys.size.should == 1
      post :destroy, :organization_id => "bad org label", :keyname => "test_key"
      response.code.should == "404"
      Organization.find(@org.id).system_info_keys.size.should == 1
    end

  end

  describe "apply default custom info to an org's existing systems" do

    before(:each) do
      (1..50).each do |i|
        System.create!(:name => "test_sys#{i}", :cp_type => "system", :environment => @env1, :facts => facts)
      end
    end

    it "should be successful", :katello => true do #TODO headpin
      @org.systems.each do |s|
        s.custom_info.empty?.should == true
      end
      @org.system_info_keys << "test_key"
      @org.save!

      get :apply_to_all_systems, :organization_id => @org.label
      response.code.should == "200"

      @org.systems.each do |s|
        s.custom_info.empty?.should == false
      end
    end

  end
end
