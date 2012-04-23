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

describe ActivationKey do

  let(:aname) { 'myactkey' }
  let(:adesc) { 'my activation key description' }

  before(:each) do
    disable_org_orchestration
    @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
    @environment_1 = KTEnvironment.create!(:name => 'dev', :prior => @organization.library.id, :organization => @organization)
    @environment_2 = KTEnvironment.create!(:name => 'test', :prior => @environment_1.id, :organization => @organization)
    @system_template_1 = SystemTemplate.create!(:name => 'template1', :environment => @environment_1) if AppConfig.katello?
    @system_template_2 = SystemTemplate.create!(:name => 'template2', :environment => @environment_1) if AppConfig.katello?
    @system_template_env2 = SystemTemplate.create!(:name => 'template3', :environment => @environment_2) if AppConfig.katello?
    @akey = ActivationKey.create!(:name => aname, :description => adesc, :organization => @organization,
                                  :environment_id => @environment_1.id, :system_template_id => @system_template_1.id) if AppConfig.katello?
    @akey = ActivationKey.create!(:name => aname, :description => adesc, :organization => @organization,
                                  :environment_id => @environment_1.id) unless AppConfig.katello?
  end

  context "in invalid state" do
    before {@akey = ActivationKey.new}

    it "should be invalid without name" do
      @akey.should_not be_valid
      @akey.errors[:name].should_not be_empty
    end

    it "should be invalid without default environment" do
      @akey.name = 'invalid key'
      @akey.should_not be_valid
      @akey.errors[:environment].should_not be_empty
    end

    it "should be invalid if non-existent environment is specified" do
      @akey.name = 'invalid key'
      @akey.environment_id = 123456

      @akey.should_not be_valid
      @akey.errors[:environment].should_not be_empty
    end

    it "should be invalid if the environment is Library" do
      @akey.name = 'invalid key'
      @akey.environment = @organization.library
      @akey.should_not be_valid
      @akey.errors[:base].should_not be_empty
    end

    it "should be invalid if environment in another org is specified" do
      org_2 = Organization.create!(:name => 'test_org2', :cp_key => 'test_org2')
      env_1_org2 = KTEnvironment.create!(:name => 'dev', :prior => org_2.library.id, :organization => org_2)
      @akey.name = 'invalid key'
      @akey.organization=@organization
      @akey.environment = env_1_org2
      @akey.should_not be_valid
      @akey.errors[:environment].should_not be_empty
    end

    it "should be invalid if system template in another environment", :katello => true do
      @akey.name = 'invalid key'
      @akey.organization=@organization
      @akey.environment = @environment_1
      @akey.system_template = @system_template_env2
      @akey.should_not be_valid
      @akey.errors[:system_template].should_not be_empty
    end

  end

  it "should be able to create" do
    @akey.should_not be_nil
  end

  describe "should be able to update" do
    it "name" do 
      a = ActivationKey.find_by_name(aname)
      a.should_not be_nil
      new_name = a.name + "N"
      b = ActivationKey.update(a.id, {:name => new_name})
      b.name.should == new_name
    end

    it "description" do 
      a = ActivationKey.find_by_name(aname)
      a.should_not be_nil
      new_description = a.description + "N"
      b = ActivationKey.update(a.id, {:description => new_description})
      b.description.should == new_description
    end
  
    it "environment" do 
      a = ActivationKey.find_by_name(aname)
      a.should_not be_nil
      b = ActivationKey.update(a.id, {:environment => @environment_2})
      b.environment.should == @environment_2
    end

    it "system template", :katello => true do
      a = ActivationKey.find_by_name(aname)
      a.should_not be_nil
      b = ActivationKey.update(a.id, {:system_template_id => @system_template_2.id})
      b.system_template_id.should == @system_template_2.id
    end
  end

  describe "pools in a activation key" do

    it "should map 2way pool to keys" do
      s = KTPool.create!(:cp_id  => 'abc123')
      @akey.pools = [s]
      @akey.pools.first.cp_id.should == 'abc123'
      s.activation_keys.first.name.should == aname
    end

    it "should assign multiple pools to keys" do
      s = KTPool.create!(:cp_id  => 'abc123')
      s2 = KTPool.create!(:cp_id  => 'def123')
      @akey.pools = [s,s2]
      @akey.pools.last.cp_id.should == 'def123'
    end

    it "should include pools details in json output" do
      pool = KTPool.create!(:cp_id  => 'abc123')
      @akey.pools << pool
      pool.reload
      @akey.as_json[:pools].should == [ { :cp_id => pool.cp_id } ]
    end
  end

  describe "#apply_to_system" do

    before(:each) do
      Pulp::Consumer.stub!(:create).and_return({:uuid => "1234", :owner => {:key => "1234"}})
      Candlepin::Consumer.stub!(:create).and_return({:uuid => "1234", :owner => {:key => "1234"}})
      @system = System.new(:name => "test", :cp_type => "system", :facts => {"distribution.name"=>"Fedora"})
    end

    it "assignes environment to the system" do
      @akey.apply_to_system(@system)
      @system.environment.should == @akey.environment
    end

    it "assignes template to the system", :katello => true do
      @akey.apply_to_system(@system)
      @system.system_template.should == @akey.system_template
    end

    it "creates an association between the activation key and the system" do
      @akey.apply_to_system(@system)
      @system.save!
      @system.activation_keys.should include(@akey)
    end

  end

  describe "#subscribe_system" do

    before(:each) do
      Candlepin::Pool.stub!(:find) do |x|
        {
          :productName => "Blah Server OS",
          :productId => dates[x][:productId],
          :startDate => dates[x][:startDate],
          :quantity => dates[x][:quantity],
          :consumed => dates[x][:consumed],
        }
      end
      @system = System.new(:name => "test", :cp_type => "system", :facts => {"distribution.name"=>"Fedora"}, :uuid => "uuid-uuid")
      @system.should_receive(:sockets).and_return(sockets)
      dates.each_pair do |k,v|
        pool = KTPool.create!(:cp_id => k)
        @akey.key_pools.create!(:pool_id  => pool.id)
      end
    end

    describe "with no pools" do
      let(:dates) do {} end
      let(:sockets) { 1 }

      it "consumes the correct entitlement" do
        @akey.pools.size.should == 0
        @akey.subscribe_system(@system)
        # no exception should be thrown
      end
    end

    describe "entitlement out of one" do
      let(:dates) do
        {
          "a" => {
            :productId => "A",
            :startDate => "2011-02-11T11:11:11.111+0000",
            :quantity => 10,
            :consumed => 0,
          }
        }
      end
      let(:sockets) { 1 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "a", 1)
        @akey.pools.size.should == 1
        @akey.subscribe_system(@system)
      end
    end

    describe "entitlement with most recent date out of two" do
      let(:dates) do
        {
          "a" => {
            :productId => "A",
            :startDate => "2011-01-02T11:11:11.111+0000",
            :quantity => 10,
            :consumed => 0,
          },
          "b" => {
            :productId => "A",
            :startDate => "2011-01-01T11:11:11.111+0000", # older
            :quantity => 10,
            :consumed => 0,
          }
        }
      end
      let(:sockets) { 1 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "b", 1)
        @akey.pools.size.should == 2
        @akey.subscribe_system(@system)
      end
    end

    describe "entitlement with least number available out of three" do
      let(:dates) do
        {
          "b" => {
            :productId => "A",
            :startDate => "2011-01-11T11:11:11.111+0000",
            :quantity => 10,
            :consumed => 0,
          },
          "c" => {
            :productId => "A",
            :startDate => "2011-01-11T11:11:11.111+0000",
            :quantity => 10,
            :consumed => 0,
          },
          "a" => {
            :productId => "A",
            :startDate => "2011-01-11T11:11:11.111+0000",
            :quantity => 10,
            :consumed => 0,
          }
        }
      end
      let(:sockets) { 1 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "a", 1)
        @akey.pools.size.should == 3
        @akey.subscribe_system(@system)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 1 entitlement in S1 (5-5)" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-11T11:11:11.111+0000",
            :quantity => 5,
            :consumed => 0,
          },
          "pool 2" => {
            :productId => "product 2",
            :startDate => "2011-01-11T11:11:11.111+0000",
            :quantity => 5,
            :consumed => 0,
          },
        }
      end
      let(:sockets) { 1 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 1)
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 1)
        @akey.subscribe_system(@system)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 8 entitlements in S2 (5-5) - older" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-02T00:00:00.000+0000",
            :quantity => 5,
            :consumed => 0,
          },
          "pool 2" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000", # older
            :quantity => 5,
            :consumed => 0,
          },
        }
      end
      let(:sockets) { 8 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 5)
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 3)
        @akey.subscribe_system(@system)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 1 entitlement in S2 (5-5) - older" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-02T00:00:00.000+0000",
            :quantity => 5,
            :consumed => 0,
          },
          "pool 2" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000", # older
            :quantity => 5,
            :consumed => 0,
          },
        }
      end
      let(:sockets) { 1 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 1)
        @akey.subscribe_system(@system)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 1 entitlement in S2 (5-5) - higher number" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000",
            :quantity => 5,
            :consumed => 0,
          },
          "pool 2" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000",
            :quantity => 5,
            :consumed => 0,
          },
        }
      end
      let(:sockets) { 1 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 1)
        @akey.subscribe_system(@system)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 2 entitlements in S1 (0-2) - zero" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000",
            :quantity => 0,
            :consumed => 0,
          },
          "pool 2" => {
            :productId => "product 2",
            :startDate => "2011-01-01T00:00:00.000+0000",
            :quantity => 2,
            :consumed => 0,
          },
        }
      end
      let(:sockets) { 2 }

      it "consumes the correct entitlement" do
        lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough entitlements/)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 2 entitlements in S1 (0-2) - all consumed" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000",
            :quantity => 99,
            :consumed => 99,
          },
          "pool 2" => {
            :productId => "product 2",
            :startDate => "2011-01-01T00:00:00.000+0000",
            :quantity => 2,
            :consumed => 0,
          },
        }
      end
      let(:sockets) { 2 }

      it "consumes the correct entitlement" do
        lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough entitlements/)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 2 entitlement(s) in S2 (0-2)" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000",
            :quantity => 5, # 0 remaining
            :consumed => 5,
          },
          "pool 2" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000",
            :quantity => 5, # 2 remaining
            :consumed => 3,
          },
        }
      end
      let(:sockets) { 2 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 2)
        @akey.subscribe_system(@system)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 2 entitlements in S1 (1-1) - first fails" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000", # older
            :quantity => 1,
            :consumed => 0,
          },
          "pool 2" => {
            :productId => "product 2",
            :startDate => "2011-01-02T00:00:00.000+0000",
            :quantity => 2, # 1 remaining
            :consumed => 1,
          },
        }
      end
      let(:sockets) { 2 }

      it "consumes the correct entitlement" do
        lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough entitlements/)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 2 entitlements in S1 (1-1) - second fails with rollback" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000", # older
            :quantity => 2,
            :consumed => 0,
          },
          "pool 2" => {
            :productId => "product 2",
            :startDate => "2011-01-02T00:00:00.000+0000",
            :quantity => 2, # 1 remaining
            :consumed => 1,
          },
        }
      end
      let(:sockets) { 2 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 2).and_return([ { "id" => "ent1" } ])
        Candlepin::Consumer.should_receive(:remove_entitlement).with(@system.uuid, "ent1")
        lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough entitlements/)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    describe "consume 2 entitlements in S2 (1-1)" do
      let(:dates) do
        {
          "pool 1" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000", # same date
            :quantity => 5, # 1 remaining
            :consumed => 4,
          },
          "pool 2" => {
            :productId => "product 1",
            :startDate => "2011-01-01T00:00:00.000+0000", # same date
            :quantity => 5, # 1 remaining
            :consumed => 4,
          },
        }
      end
      let(:sockets) { 2 }

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 1)
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 1)
        @akey.subscribe_system(@system)
      end
    end

  end

end
