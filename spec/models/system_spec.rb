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
include OrchestrationHelper

describe System do

  let(:facts) { {"distribution.name" => "Fedora"} }
  let(:system_name) { 'testing' }
  let(:cp_type) { 'system' }
  let(:uuid) { '1234' }
  let(:href) { '/blah' }
  let(:entitlements) { {} }
  let(:pools) { {} }
  let(:available_pools) { {} }
  let(:description) { 'description' }
  let(:package_profile) {
    [{"epoch" => 0, "name" => "im-chooser", "arch" => "x86_64", "version" => "1.4.0", "vendor" => "Fedora Project", "release" => "1.fc14"},
     {"epoch" => 0, "name" => "maven-enforcer-api", "arch" => "noarch", "version" => "1.0", "vendor" => "Fedora Project", "release" => "0.1.b2.fc14"},
     {"epoch" => 0, "name" => "ppp", "arch" => "x86_64", "version" => "2.4.5", "vendor" => "Fedora Project", "release" => "12.fc14"},
     {"epoch" => 0, "name" => "pulseaudio-module-bluetooth", "arch" => "x86_64", "version" => "0.9.21", "vendor" => "Fedora Project", "release" => "7.fc14"},
     {"epoch" => 0, "name" => "dbus-cxx-glibmm", "arch" => "x86_64", "version" => "0.7.0", "vendor" => "Fedora Project", "release" => "2.fc14.1"},
     {"epoch" => 0, "name" => "twolame-libs", "arch" => "x86_64", "version" => "0.3.12", "vendor" => "RPM Fusion", "release" => "4.fc11"},
     {"epoch" => 0, "name" => "gtk-vnc", "arch" => "x86_64", "version" => "0.4.2", "vendor" => "Fedora Project", "release" => "4.fc14"}]
  }

  before(:each) do
    disable_org_orchestration

    @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
    @environment = KPEnvironment.create!(:name => 'test', :prior => @organization.locker.id, :organization => @organization)

    Organization.stub!(:first).and_return(@organization)

    @system = System.new(:name => system_name, :environment => @environment, :cp_type => cp_type, :facts => facts, :description => description, :uuid => uuid)

    Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Candlepin::Consumer.stub!(:update).and_return(true)
    
    Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
  end

  context "system in invalid state should not be valid" do
    before(:each) { @system = System.new }
    specify { System.new(:name => 'name', :environment => @organization.environments.first, :cp_type => cp_type).should_not be_valid }
    specify { System.new(:name => 'name', :environment => @organization.environments.first, :facts => facts).should_not be_valid }
    specify { System.new(:cp_type => cp_type, :environment => @organization.environments.first, :facts => facts).should_not be_valid }
    specify { System.new(:name => system_name, :environment => @organization.locker, :cp_type => cp_type, :facts => facts).should_not be_valid }
  end

  it "registers system in candlepin and pulp on create" do
    #debugger
    Candlepin::Consumer.should_receive(:create).once.with(@organization.name, system_name, cp_type, facts).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Pulp::Consumer.should_receive(:create).once.with(@organization.cp_key, uuid, description).and_return({:uuid => uuid, :owner => {:key => uuid}})
    @system.save!
  end

  context "delete system" do
    before(:each) {
      @system.save!
    }

    it "should delete consumer in candlepin and pulp" do
      Candlepin::Consumer.should_receive(:destroy).once.with(uuid).and_return(true)
      Pulp::Consumer.should_receive(:destroy).once.with(uuid).and_return(true)
      @system.destroy
    end
  end

  context "regenerate identity certificates" do
    before { @system.uuid = uuid }

    it "should call Candlepin::Consumer.regenerate_identity_certificates" do
      Candlepin::Consumer.should_receive(:regenerate_identity_certificates).once.with(uuid).and_return(true)
      @system.regenerate_identity_certificates
    end
  end
  context "subscribe an entitlement" do
    before { @system.uuid = uuid }

    it "should call Candlepin::Consumer.consume_entitlement" do
      pool_id = "foo"
      Candlepin::Consumer.should_receive(:consume_entitlement).once.with(uuid,pool_id).and_return(true)
      @system.subscribe pool_id
    end
  end
  context "update system" do
    before(:each) do
      @system.save!
      @system.facts = facts
    end

    it "should call Candlepin::Consumer.update" do
      Candlepin::Consumer.should_receive(:update).once.with(uuid, facts).and_return(true)
      @system.save!
    end
s  end

  context "persisted system has correct attributes" do
    before(:each) { @system.save! }

    specify { System.all.size.should == 1 }
    specify { System.first.name.should == system_name }
    specify { System.first.uuid.should == uuid }
    specify { System.first.organization.id.should == @organization.id }
  end

  context "cp attributes" do
    context "in persisted object" do
      before(:each) do
        @system.uuid = uuid
        @system.save
        Candlepin::Consumer.stub!(:get).and_return({:href => href, :uuid => uuid})
        Candlepin::Consumer.stub!(:entitlements).and_return({})        
        Candlepin::Consumer.stub!(:available_pools).and_return([])
      end

      it "should access candlepin if uninialized" do
        Candlepin::Consumer.should_receive(:get).once.with(uuid).and_return({:href => href, :uuid => uuid})
        @system.href
      end

      specify { @system.href.should == href }
      specify { @system.uuid.should == uuid }
      specify { @system.cp_type.should == cp_type }

      it "should access candlepin if entitlements is uninialized" do
        Candlepin::Consumer.should_receive(:entitlements).once.with(uuid).and_return({})
        @system.entitlements
      end

      context "shouldn't access candlepin if initialized" do
        before(:each) do
          @system.href = href
          @system.entitlements = entitlements
          @system.save

          Candlepin::Consumer.should_not_receive(:get)
          Candlepin::Consumer.should_not_receive(:entitlements)
        end

        specify { @system.href.should == href; }
        specify { @system.entitlements.should == entitlements; }
      end
      
      it "should access candlepin if pools is uninialized" do
        Candlepin::Consumer.should_receive(:entitlements).once.with(uuid).and_return([{"pool" => {"id" => 100}}])
        Candlepin::Pool.should_receive(:get).once.and_return({})
        @system.pools
      end

      context "shouldn't access candlepin pools if initialized" do
        before(:each) do
          @system.href = href
          @system.pools = {}
          Candlepin::Consumer.should_not_receive(:get)
          Candlepin::Consumer.should_not_receive(:entitlements)
          Candlepin::Pool.should_not_receive(:get)
        end

        specify { @system.href.should == href }
        specify { @system.pools.should == pools }
      end

      it "should access candlepin if available_pools is uninialized" do
        Candlepin::Consumer.should_receive(:available_pools).once.with(uuid).and_return([])
        @system.available_pools
      end

      context "shouldn't access candlepin available_pools if initialized" do
        before(:each) do
          @system.available_pools = available_pools
          Candlepin::Consumer.should_not_receive(:get)
          Candlepin::Consumer.should_not_receive(:available_pools)
        end
        specify { @system.available_pools.should == available_pools }
      end      
      
    end

    context "shouldn't access candlepin if new record" do
      before(:each) { Candlepin::Consumer.should_not_receive(:get) }
      specify { @system.href.should be_nil }
    end
  end
  
  context "pulp attributes" do
    it "should update package-profile" do
      Pulp::Consumer.should_receive(:upload_package_profile).once.with(uuid, package_profile).and_return(true)
      @system.upload_package_profile(package_profile)
    end
  end

end
