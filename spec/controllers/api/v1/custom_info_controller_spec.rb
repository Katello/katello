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

require 'katello_test_helper'
module Katello
describe Api::V1::CustomInfoController do
  include OrchestrationHelper
  include SystemHelperMethods

  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include OrganizationHelperMethods


  let(:facts) { { "distribution.name" => "Fedora" } }
  let(:uuid) { '1234' }

  before (:each) do
    setup_controller_defaults_api

    disable_org_orchestration
    disable_consumer_group_orchestration
    disable_system_orchestration

    Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid, :owner => { :key => uuid } })

    Katello.pulp_server.extensions.consumer.stubs(:create).returns({ :id => uuid }) if Katello.config.katello?

    @org  = Organization.create!(:name => "test_org", :label => "test_org")
    @env1 = create_environment(:name => "test_env", :label => "test_env", :prior => @org.library.id, :organization => @org)

    @system = create_system(:name => "test_sys", :cp_type => "system", :environment => @env1, :facts => facts)

    CustomInfo.skip_callback(:save, :after, :reindex_informable)
    CustomInfo.skip_callback(:destroy, :after, :reindex_informable)
  end

  describe "create custom infoz" do

    it "should return 200 with successful create" do
      System.find(@system.id).custom_info.size.must_equal 0
      post :create, :informable_id => @system.id, :informable_type => "system", :keyname => "test_key", :value => "test_value"
      response.code.must_equal "200"
      System.find(@system.id).custom_info.size.must_equal 1
    end

    it "should require valid informable type" do
      System.find(@system.id).custom_info.empty?.must_equal true
      post :create, :informable_id => @system.id, :informable_type => "systemic", :keyname => "test_key", :value => "test_value"
      response.code.must_equal "500"
      System.find(@system.id).custom_info.empty?.must_equal true
    end

    it "should require valid system id" do
      System.find(@system.id).custom_info.empty?.must_equal true
      post :create, :informable_id => (@system.id + 2), :informable_type => "system", :keyname => "test_key", :value => "test_value"
      response.code.must_equal "404"
      System.find(@system.id).custom_info.empty?.must_equal true
    end

    it "should require key + value pairs" do
      System.find(@system.id).custom_info.empty?.must_equal true
      post :create, :informable_id => @system.id, :informable_type => "system"
      response.code.must_equal "422"
      System.find(@system.id).custom_info.empty?.must_equal true
    end
  end

  describe "index custom infoz" do

    before(:each) do
      @system.custom_info.create(:keyname => "test_key1", :value => "test_value1")
      @system.custom_info.create(:keyname => "test_key2", :value => "test_value2")
      @system.custom_info.create(:keyname => "test_key3", :value => "test_value3")
    end

    it "should return 200 with successful index" do
      get :index, :informable_id => @system.id, :informable_type => "system"
      response.code.must_equal "200"
    end

    it "should require valid informable type" do
      get :index, :informable_id => @system.id, :informable_type => "super duper"
      response.code.must_equal "500"
    end

    it "should require valid informable id" do
      get :index, :informable_id => 9001, :informable_type => "system"
      response.code.must_equal "404"
    end
  end

  describe "show custom info" do

    before(:each) do
      @system.custom_info.create(:keyname => "test_key1", :value => "test_value1")
      @system.custom_info.create(:keyname => "test_key2", :value => "test_value2")
      @system.custom_info.create(:keyname => "test_key3", :value => "test_value3")
      @system.custom_info.create(:keyname => "<blink>fookey</blink>", :value => "<blink>foovalue</blink>")
    end

    it "should return 200 with successful show" do
      get :show, :informable_id => @system.id, :informable_type => "system", :keyname => "test_key1"
      response.code.must_equal "200"
    end

    it "should show custom info that has html in the keyname" do
      get :show, :informable_id => @system.id, :informable_type => "system", :keyname => "<blink>fookey</blink>"
      response.code.must_equal "200"
    end

    it "should require valid  informable type" do
      get :show, :informable_id => @system.id, :informable_type => "orange juice", :keyname => "test_key2"
      response.code.must_equal "500"
    end

    it "should require valid informable id" do
      get :show, :informable_id => -5, :informable_type => "system", :keyname => "test_key3"
      response.code.must_equal "404"
    end

    it "should 404 if keyname is not found" do
      get :show, :informable_id => @system.id, :informable_type => "system", :keyname => "redhat"
      response.code.must_equal "404"
    end
  end

  describe "update custom info" do

    before(:each) do
      @system.custom_info.create(:keyname => "test_key1", :value => "test_value1")
      @system.custom_info.create(:keyname => "test_key2", :value => "test_value2")
      @system.custom_info.create(:keyname => "test_key3", :value => "test_value3")
      @system.custom_info.create(:keyname => "<blink>fookey</blink>", :value => "<blink>foovalue</blink>")
    end

    it "should return 200 with successful update" do
      System.find(@system.id).custom_info.size.must_equal 4
      System.find(@system.id).custom_info.where(:keyname => "test_key1", :value => "test_value1").size.must_equal 1
      System.find(@system.id).custom_info.where(:keyname => "test_key1", :value => "super_test_value1").size.must_equal 0
      put :update, :informable_id => @system.id, :informable_type => "system", :keyname => "test_key1", :value => "super_test_value1"
      response.code.must_equal "200"
      System.find(@system.id).custom_info.where(:keyname => "test_key1", :value => "test_value1").size.must_equal 0
      System.find(@system.id).custom_info.where(:keyname => "test_key1", :value => "super_test_value1").size.must_equal 1
      System.find(@system.id).custom_info.size.must_equal 4
    end

    it "should return 200 with successful update on keyname with html characters" do
      put :update, :informable_id => @system.id, :informable_type => "system", :keyname => "<blink>fookey</blink>", :value => "<blink>superfoovalue</blink>"
      response.code.must_equal "200"
    end

    it "should require valid informable type" do
      System.find(@system.id).custom_info.size.must_equal 4
      System.find(@system.id).custom_info.where(:keyname => "test_key1", :value => "test_value1").size.must_equal 1
      put :update, :informable_id => @system.id, :informable_type => "telephone", :keyname => "test_key1", :value => "super_test_value1"
      response.code.must_equal "500"
      System.find(@system.id).custom_info.where(:keyname => "test_key1", :value => "test_value1").size.must_equal 1
      System.find(@system.id).custom_info.size.must_equal 4
    end

    it "should require valid informable id" do
      System.find(@system.id).custom_info.where(:keyname => "test_key1", :value => "test_value1").size.must_equal 1
      System.find(@system.id).custom_info.size.must_equal 4
      put :update, :informable_id => (@system.id + 3), :informable_type => "system", :keyname => "test_key1", :value => "super_test_value1"
      response.code.must_equal "404"
      System.find(@system.id).custom_info.where(:keyname => "test_key1", :value => "test_value1").size.must_equal 1
      System.find(@system.id).custom_info.size.must_equal 4
    end

    it "should respond with 404 if custom info cannot be found" do
      System.find(@system.id).custom_info.size.must_equal 4
      put :update, :informable_id => @system.id, :informable_type => "system", :keyname => "super_test_key1", :value => "chuck norris"
      response.code.must_equal "404"
      System.find(@system.id).custom_info.size.must_equal 4
    end
  end

  describe "delete custom info" do

    before(:each) do
      @system.custom_info.create(:keyname => "test_key1", :value => "test_value1")
      @system.custom_info.create(:keyname => "test_key2", :value => "test_value2")
      @system.custom_info.create(:keyname => "test_key3", :value => "test_value3")

      @system.custom_info.create(:keyname => "test_key4", :value => "test_value4")
      @system.custom_info.create(:keyname => "test_key5", :value => "test_value5")
      @system.custom_info.create(:keyname => "<blink>fookey</blink>", :value => "<blink>foovalue</blink>")
    end

    it "should return 200 with success" do
      @system.custom_info.size.must_equal 6
      @system.custom_info.where(:keyname => "test_key1").size.must_equal 1
      delete :destroy, :informable_id => @system.id, :informable_type => "system", :keyname => "test_key1"
      response.code.must_equal "200"
      @system.custom_info.where(:keyname => "test_key1").size.must_equal 0
      @system.custom_info.size.must_equal 5
    end

    it "should return 200 with success with html characters in the keyname" do
      delete :destroy, :informable_id => @system.id, :informable_type => "system", :keyname => "<blink>fookey</blink>"
      response.code.must_equal "200"
    end

    it "should respond 404 if keyname cannot be found" do
      @system.custom_info.size.must_equal 6
      delete :destroy, :informable_id => @system.id, :informable_type => "system", :keyname => "super_test_key1"
      response.code.must_equal "404"
      @system.custom_info.size.must_equal 6
    end

    it "should require valid informable type" do
      @system.custom_info.size.must_equal 6
      delete :destroy, :informable_id => @system.id, :informable_type => "super informed", :keyname => "test_key1"
      response.code.must_equal "500"
      @system.custom_info.size.must_equal 6
    end

    it "should require valid informable id" do
      @system.custom_info.size.must_equal 6
      delete :destroy, :informable_id => (@system.id + 5), :informable_type => "system", :keyname => "test_key1"
      response.code.must_equal "404"
      @system.custom_info.size.must_equal 6
    end
  end
end
end