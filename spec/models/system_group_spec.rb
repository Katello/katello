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



describe SystemGroup do

  include SystemHelperMethods
  include OrchestrationHelper

  let(:uuid) { '1234' }

  before(:each) do
    disable_org_orchestration
    disable_consumer_group_orchestration
    @org = Organization.create!(:name => 'test_org', :cp_key => 'test_org')

    @group = SystemGroup.create!(:name=>"TestSystemGroup", :organization=>@org)

    setup_system_creation
    Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Candlepin::Consumer.stub!(:update).and_return(true)
    @environment = KTEnvironment.create!(:name=>"DEV", :prior=>@org.library, :organization=>@org)
    @system = System.create!(:name=>"bar1", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
  end

  context "create should" do

    it "should create succesfully with an org" do
      Pulp::ConsumerGroup.should_receive(:create).and_return({})
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp.pulp_id.should_not == nil
    end

    it "should not allow creation of a 2nd group in the same org with the same name" do
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp2 = SystemGroup.create(:name=>"TestGroup", :organization=>@org)
      grp2.new_record?.should == true
      SystemGroup.where(:name=>"TestGroup").count.should == 1
    end

    it "should allow systems groups with the same name to be creatd in different orgs" do
      @org2 = Organization.create!(:name => 'test_org2', :cp_key => 'test_org2')
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp2 = SystemGroup.create(:name=>"TestGroup", :organization=>@org2)
      grp2.new_record?.should == false
      SystemGroup.where(:name=>"TestGroup").count.should == 2
    end
  end

  context "delete should" do
    it "should delete a group successfully" do
      Pulp::ConsumerGroup.should_receive(:destroy).and_return(200)
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

  context "changing consumer ids"  do
    it "should contact pulp if new ids are added" do
      Pulp::ConsumerGroup.should_receive(:add_consumer).twice
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org, :consumerids=>[:a, :b])
      grp.consumerids = [:a, :b, :c, :d]
      grp.save!
    end
    it "should contact pulp if new ids are removed" do
      Pulp::ConsumerGroup.should_receive(:delete_consumer).twice
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org, :consumerids=>[:a, :b])
      grp.consumerids = []
      grp.save!
    end
    it "should contact pulp if new ids are added and removed" do
      Pulp::ConsumerGroup.should_receive(:add_consumer).twice
      Pulp::ConsumerGroup.should_receive(:delete_consumer).twice
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org, :consumerids=>[:a, :b])
      grp.consumerids = [:c, :d]
      grp.save!
    end
  end

  context "changing systems" do
    it "should call out to pulp when adding" do
      Pulp::ConsumerGroup.should_receive(:add_consumer).once
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp.systems << @system
      grp.save!
    end
    it "should call out to pulp when removing" do
      Pulp::ConsumerGroup.should_receive(:add_consumer).once
      Pulp::ConsumerGroup.should_receive(:delete_consumer).once
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org, :systems=>[@system])
      grp.systems = grp.systems - [@system]
      grp.save!
    end

    it "should not be allowed to add if locked" do
      @group.locked = true
      @group.save!
      lambda{
        @group.systems = [@system]
        @group.save!
      }.should raise_error
    end

    it "should not be allowed to remove if locked" do
      @group.systems = [@system]
      @group.save!
      @group.locked = true
      @group.save!
      lambda{
        @group.systems = []
        @group.save!
      }.should raise_error
    end

  end


  context "changing environments" do
    it "should allow an environment to be set" do
      @group.environments = [@environment]
      @group.save!
      SystemGroup.find(@group.id).environments.should include @environment
    end

    it "should allow an environment to be appended to" do
      @group.environments << @environment
      @group.save!
      SystemGroup.find(@group.id).environments.should include @environment
    end

    it "should not allow access to db_environments" do
      @group.environments << @environment
      @group.save!
      lambda{@group.db_environments}.should raise_exception
    end
    it "should not allow access to db_environment_ids" do
      @group.environments << @environment
      @group.save!
      lambda{@group.db_environment_ids}.should raise_exception
    end
  end

  context "systems should respect environments" do
    before :each do
      @environment2 = KTEnvironment.create!(:name=>"DEV2", :prior=>@org.library, :organization=>@org)
    end

    it "should allow any system to be added to a group without environments" do
      @group.systems = [@system]
      @group.save!
      @group.reload.systems.should include @system
    end

    it "should allow a system to be added to a group with that systems environment" do
      @group.environments = [@environment]
      @group.systems = [@system]
      @group.save!
      @group.reload.systems.should include @system
    end

    it "should not allow a system to be added to a group with that systems environment" do
      @group.environments = [@environment2]
      @group.save!
      @group.reload.environments.should include @environment2
      lambda{ @group.systems = [@system]
              @group.save! }.should raise_exception
      SystemGroup.find(@group.id).systems.should_not include @system
    end
  end

  context "environments should respect systems" do
    before :each do
      @environment2 = KTEnvironment.create!(:name=>"DEV2", :prior=>@org.library, :organization=>@org)
      @group.systems = [@system]
      @group.save!
    end
    it "should allow an environment to be added if its systems are in it'" do
      @group.environments = [@environment]
      @group.save!
      SystemGroup.find(@group.id).systems.should include @system
      SystemGroup.find(@group.id).environments.should include @environment
    end

    it "should allow an environment to be removed if it means there are no more environments'" do
      @group.environments = [@environment]
      @group.save!
      @group.environments = []
      @group.save!
      SystemGroup.find(@group.id).systems.should include @system
      SystemGroup.find(@group.id).environments.should == []
    end

    it "should not allow an environment to be added if its systems are not in it" do
      lambda{ @group.environments = [@environment2]
              @group.save!}.should raise_exception
      SystemGroup.find(@group.id).systems.should include @system
      SystemGroup.find(@group.id).environments.should_not include @environment2
    end

    it "should not allow an environment to be removed if its systems are only in it" do
      @group.environments = [@environment2, @environment]
      @group.save!
      @group = SystemGroup.find(@group.id)
      @group.environments.should include @environment
      @group.environments.should include @environment2
      lambda{
        @group.environments = [@environment2]
        @group.save!
      }.should raise_exception
    end

  end


end
