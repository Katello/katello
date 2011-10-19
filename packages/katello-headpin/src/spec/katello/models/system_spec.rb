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
    @environment = KTEnvironment.create!(:name => 'test', :prior => @organization.locker.id, :organization => @organization)

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

  context "delete system" do
    before(:each) {
      @system.save!
    }

    it "should delete consumer in pulp" do
      Pulp::Consumer.should_receive(:destroy).once.with(uuid).and_return(true)
      @system.destroy
    end
  end

  context "pulp attributes" do
    it "should update package-profile" do
      Pulp::Consumer.should_receive(:upload_package_profile).once.with(uuid, package_profile).and_return(true)
      @system.upload_package_profile(package_profile)
    end
  end

end
