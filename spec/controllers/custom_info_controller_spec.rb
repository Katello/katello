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

require 'spec_helper'

describe CustomInfoController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrchestrationHelper
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

    @system = System.create!(:name => "test_sys", :cp_type => "system", :environment => @env1, :facts => facts)

    CustomInfo.skip_callback(:save, :after, :reindex_informable)
    CustomInfo.skip_callback(:destroy, :after, :reindex_informable)

  end

  describe "creation" do

    before(:each) do
      @expected_create_response = {
        :keyname => "asset_tag",
        :value => "123456",
        :informable_type => "system",
        :informable_id => @system.id
      }.to_json
    end

    it "should create successfully" do
      ci_count = System.find(@system.id).custom_info.size
      post :create, :informable_type => "system", :informable_id => @system.id, :keyname => "asset_tag", :value => "123456"
      response.code.should == "200"
      response.body.should == @expected_create_response
      System.find(@system.id).custom_info.size.should == (ci_count + 1)
    end
  end

  describe "update" do
    before(:each) do
      @system.custom_info.create!(:keyname => "asset_tag", :value => "1234")
    end

    it "should update successfully" do
      ci_count = System.find(@system.id).custom_info.size
      put :update, :informable_type => "system", :informable_id => @system.id, :keyname => "asset_tag", :value => "5678", :custom_info => { :asset_tag => "5678" }
      response.code.should == "200"
      response.body.should == "5678"
      System.find(@system.id).custom_info.size.should == ci_count
    end
  end

  describe "destroy" do
    before(:each) do
      @system.custom_info.create!(:keyname => "asset_tag", :value => "1234")
    end

    it "should destroy successfully" do
      ci_count = System.find(@system.id).custom_info.size
      delete :destroy, :informable_type => "system", :informable_id => @system.id, :keyname => "asset_tag"
      response.code.should == "200"
      response.body.should == "true"
      System.find(@system.id).custom_info.size.should == ci_count - 1
    end
  end

end
