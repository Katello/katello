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

describe SystemGroup do

  include OrganizationHelperMethods
  include SystemHelperMethods
  include OrchestrationHelper

  let(:uuid) { '1234' }

  before(:each) do
    disable_org_orchestration
    @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
    @group = SystemGroup.create!(:name=>"TestSystemGroup", :organization=>@org)

    setup_system_creation
    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)

    @environment = create_environment(:name=>"DEV", :label=> "DEV", :prior=>@org.library, :organization=>@org)
    @system = create_system(:name=>"bar1", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
  end

  context "create should" do

    it "should create succesfully with an org", :katello => true do
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp.should_not == nil
    end

    it "should not allow creation of a 2nd group in the same org with the same name" do
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp2 = SystemGroup.create(:name=>"TestGroup", :organization=>@org)
      grp2.new_record?.should == true
      SystemGroup.where(:name=>"TestGroup").count.should == 1
    end

    it "should allow systems groups with the same name to be creatd in different orgs" do
      @org2 = Organization.create!(:name=>'test_org2', :label=> 'test_org2')
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp2 = SystemGroup.create(:name=>"TestGroup", :organization=>@org2)
      grp2.new_record?.should == false
      SystemGroup.where(:name=>"TestGroup").count.should == 2
    end
  end

  context "delete should" do
    it "should delete a group successfully", :katello => true do
      @group.destroy
      SystemGroup.where(:name=>@group.name).count.should == 0
    end
  end

  context "update should" do

    it "should allow the name to change" do
      @group.name = "NotATestGroup"
      @group.save!
      SystemGroup.where(:name=>"NotATestGroup").count.should == 1
    end
  end


  context "changing systems", :katello => true do
    it "should allow systems to be added" do
      @system.should_receive(:update_system_groups)
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp.systems << @system
      grp.save!
      SystemGroup.find(grp).consumer_ids.size.should == 1
    end

    it "should call allow ids to be removed" do
      @system.should_receive(:update_system_groups).twice
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp.systems << @system
      grp.systems = grp.systems - [@system]
      grp.save!
      SystemGroup.find(grp).consumer_ids.size.should == 0
    end
  end

  context "actions", :katello => true do
    it "should raise exception on package install, if no systems in group" do
      lambda{ @group.install_packages("pkg1")}.should raise_exception(Errors::SystemGroupEmptyException)
    end

    it "should raise exception on package update, if no systems in group" do
      lambda{ @group.update_packages("pkg1")}.should raise_exception(Errors::SystemGroupEmptyException)
    end

    it "should raise exception on package remove, if no systems in group" do
      lambda{ @group.uninstall_packages("pkg1")}.should raise_exception(Errors::SystemGroupEmptyException)
    end

    it "should raise exception on package group install, if no systems in group" do
      lambda{ @group.install_package_groups("grp1")}.should raise_exception(Errors::SystemGroupEmptyException)
    end

    it "should raise exception on package group remove, if no systems in group" do
      lambda{ @group.uninstall_package_groups("grp1")}.should raise_exception(Errors::SystemGroupEmptyException)
    end

    it "should raise exception on errata install, if no systems in group" do
      lambda{ @group.install_errata("errata1")}.should raise_exception(Errors::SystemGroupEmptyException)
    end
  end

end
