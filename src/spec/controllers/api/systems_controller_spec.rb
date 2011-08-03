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
  let(:package_profile) {
    [{"epoch" => 0, "name" => "im-chooser", "arch" => "x86_64", "version" => "1.4.0", "vendor" => "Fedora Project", "release" => "1.fc14"},
     {"epoch" => 0, "name" => "maven-enforcer-api", "arch" => "noarch", "version" => "1.0", "vendor" => "Fedora Project", "release" => "0.1.b2.fc14"},
     {"epoch" => 0, "name" => "ppp", "arch" => "x86_64", "version" => "2.4.5", "vendor" => "Fedora Project", "release" => "12.fc14"},
     {"epoch" => 0, "name" => "pulseaudio-module-bluetooth", "arch" => "x86_64", "version" => "0.9.21", "vendor" => "Fedora Project", "release" => "7.fc14"},
     {"epoch" => 0, "name" => "dbus-cxx-glibmm", "arch" => "x86_64", "version" => "0.7.0", "vendor" => "Fedora Project", "release" => "2.fc14.1"},
     {"epoch" => 0, "name" => "twolame-libs", "arch" => "x86_64", "version" => "0.3.12", "vendor" => "RPM Fusion", "release" => "4.fc11"},
     {"epoch" => 0, "name" => "gtk-vnc", "arch" => "x86_64", "version" => "0.4.2", "vendor" => "Fedora Project", "release" => "4.fc14"}]
  }

  before (:each) do
    login_user
    set_default_locale
    disable_org_orchestration

    Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Candlepin::Consumer.stub!(:update).and_return(true)
    
    Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})

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
  
  describe "update package profile" do
    it "successfully" do
      @sys = System.new(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
      
      Pulp::Consumer.should_receive(:upload_package_profile).once.with(uuid, package_profile).and_return(true)
      System.stub!(:first).and_return(@sys)
      put :upload_package_profile, :id => uuid, :_json => package_profile
      response.body.should == @sys.to_json
    end
  end

  describe "list errata" do
    before(:each) do
      @system = System.new(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
      System.stub!(:first).and_return(@system)
    end

    it "should find System" do
      System.should_receive(:first).once.with(hash_including(:conditions => {:uuid => @system.uuid})).and_return(@system)
      get :errata, :id => @system.uuid
    end

    it "should retrieve Consumer's errata from pulp" do
      Pulp::Consumer.should_receive(:errata).once.with(uuid).and_return([])
      get :errata, :id => @system.uuid
    end
  end

end
