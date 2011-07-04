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

require 'spec_helper.rb'
include OrchestrationHelper

describe Api::SystemsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods

  let(:facts) { {"distribution.name" => "Fedora"} }
  let(:uuid) { '1234' }

  before (:each) do
    login_user
    set_default_locale
    disable_org_orchestration

    Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Candlepin::Consumer.stub!(:update).and_return(true)

    @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
  end

  describe "create a system" do
    it "requires either environment_id, owner, or organization_id to be specified" do
      post :create
      response.code.should == "400"
    end

    context "in organization with one environment" do
      before(:each) do
        @environment_1 = KPEnvironment.new(:name => 'test_1', :prior => @organization.locker.id, :organization => @organization)
        @environment_1.save!
      end

      it "requires either organization_id" do
        System.should_receive(:create!).with(hash_including(:environment => @environment_1, :cp_type => 'system', :facts => facts, :name => 'test')).once.and_return({})
        post :create, :organization_id => @organization.cp_key, :name => 'test', :cp_type => 'system', :facts => facts
      end

      it "or requires owner (key)" do
        System.should_receive(:create!).with(hash_including(:environment => @environment_1, :cp_type => 'system', :facts => facts, :name => 'test')).once.and_return({})
        post :create, :owner => @organization.cp_key, :name => 'test', :cp_type => 'system', :facts => facts
      end
    end

    context "in organization with multiple environments" do
      before(:each) do
        @environment_1 = KPEnvironment.new(:name => 'test_1', :prior => @organization.locker.id, :organization => @organization)
        @environment_1.save!
        @environment_2 = KPEnvironment.new(:name => 'test_2', :prior => @environment_1, :organization => @organization)
        @environment_2.save!
      end

      it "requires environment id" do
        System.should_receive(:create!).with(hash_including(:environment => @environment_1, :cp_type => 'system', :facts => facts, :name => 'test')).once.and_return({})
        post :create, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system', :facts => facts
      end

      it "fails if no environment_id was specified" do
        post :create, :organization_id => @organization.cp_key
        response.code.should == "400"
      end
    end
  end

  describe "list systems" do
    before(:each) do
      @environment_1 = KPEnvironment.new(:name => 'test_1', :prior => @organization.locker.id, :organization => @organization)
      @environment_1.save!
      @environment_2 = KPEnvironment.new(:name => 'test_2', :prior => @environment_1, :organization => @organization)
      @environment_2.save!

      @system_1 = System.create!(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts)
      @system_2 = System.create!(:name => 'test', :environment => @environment_2, :cp_type => 'system', :facts => facts)
    end

    it "requires either organization_id, owner, or environment_id" do
      get :index
      response.code.should == "400"
    end

    it "should show all systems in the organization" do
      get :index, :organization_id => @organization.cp_key
      response.body.should == [@system_1, @system_2].to_json
    end

    it "should show all systems for the owner" do
      get :index, :owner => @organization.cp_key
      response.body.should == [@system_1, @system_2].to_json
    end

    it "should show only systems in the environment" do
      get :index, :environment_id => @environment_1.id
      response.body.should == [@system_1].to_json
    end

  end

end
