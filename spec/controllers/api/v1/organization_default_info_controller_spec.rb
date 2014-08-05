#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
describe Api::V1::OrganizationDefaultInfoController do
  include OrganizationHelperMethods

  include OrchestrationHelper
  include SystemHelperMethods
  let(:facts) { { "distribution.name" => "Fedora" } }
  let(:uuid) { '1234' }

  before(:each) do
    setup_controller_defaults_api
    disable_org_orchestration
    disable_consumer_group_orchestration
    disable_system_orchestration

    Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid, :owner => { :key => uuid } })

    Katello.pulp_server.extensions.consumer.stubs(:create).returns({ :id => uuid }) if Katello.config.app_mode == "katello"

    @org  = Organization.create!(:name => "test_org", :label => "test_org")
    @env1 = create_environment(:name => "test_env", :label => "test_env", :prior => @org.library.id, :organization => @org)

    CustomInfo.skip_callback(:save, :after, :reindex_informable)
    CustomInfo.skip_callback(:destroy, :after, :reindex_informable)
  end

  describe "add default custom info to an org" do

    it "should be successful" do
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
      post :create, :organization_id => @org.label, :keyname => "test_key", :informable_type => "system"
      response.code.must_equal "200"
      Organization.find(@org.id).default_info["system"].include?("test_key").must_equal true
    end

    it "should be successful with html characters in the keyname" do
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
      post :create, :organization_id => @org.label, :keyname => "<blink>fookey</blink>", :informable_type => "system"
      response.code.must_equal "200"
      Organization.find(@org.id).default_info["system"].include?("<blink>fookey</blink>").must_equal true
    end

    it "should fail without keyname" do
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
      post :create, :organization_id => @org.label, :informable_type => "system"
      response.code.must_equal "422"
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
    end

    it "should fail with wrong org id" do
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
      post :create, :organization_id => "blahblahblah", :keyname => "test_key", :informable_type => "system"
      response.code.must_equal "404"
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
    end

    it "should throw an error when you add default info that is already there" do
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
      post :create, :organization_id => @org.label, :keyname => "test_key", :informable_type => "system"
      response.code.must_equal "200"
      Organization.find(@org.id).default_info["system"].size.must_equal 1

      setup_controller_defaults_api
      post :create, :organization_id => @org.label, :keyname => "test_key", :informable_type => "system"
      response.code.must_equal "400"
      Organization.find(@org.id).default_info["system"].size.must_equal 1
    end

    it "should fail if the type given is not an accepted type" do
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
      post :create, :organization_id => "blahblahblah", :keyname => "test_key", :informable_type => "nonstandardtype"
      response.code.must_equal "404"
      Organization.find(@org.id).default_info["system"].empty?.must_equal true
    end

  end

  describe "remove default custom info to an org" do

    before(:each) do
      @org.default_info["system"] << "test_key"
      @org.default_info["system"] << "<blink>fookey</blink>"
      @org.save!
    end

    it "should be successful" do
      Organization.find(@org.id).default_info["system"].size.must_equal 2
      post :destroy, :organization_id => @org.label, :keyname => "test_key", :informable_type => "system"
      response.code.must_equal "200"
      Organization.find(@org.id).default_info["system"].size.must_equal 1
    end

    it "should be successful with html characters in the keyname" do
      Organization.find(@org.id).default_info["system"].size.must_equal 2
      post :destroy, :organization_id => @org.label, :keyname => "<blink>fookey</blink>", :informable_type => "system"
      response.code.must_equal "200"
      Organization.find(@org.id).default_info["system"].size.must_equal 1
    end

    it "should fail with wrong org id" do
      Organization.find(@org.id).default_info["system"].size.must_equal 2
      post :destroy, :organization_id => "bad org label", :keyname => "test_key", :informable_type => "system"
      response.code.must_equal "404"
      Organization.find(@org.id).default_info["system"].size.must_equal 2
    end

    it "should raise error with a bad keyname" do
      Organization.find(@org.id).default_info["system"].include?("bad_keyname").must_equal false
      post :destroy, :organization_id => @org.label, :keyname => "bad_keyname", :informable_type => "system"
      response.code.must_equal "404"
    end

  end
end
end
