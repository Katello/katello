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
    @environment_1 = KTEnvironment.create!(:name => 'dev', :prior => @organization.locker.id, :organization => @organization)
    @environment_2 = KTEnvironment.create!(:name => 'test', :prior => @environment_1.id, :organization => @organization)
    @system_template_1 = SystemTemplate.create!(:name => 'template1', :environment => @environment_1) if AppConfig.katello?
    @system_template_2 = SystemTemplate.create!(:name => 'template2', :environment => @environment_1) if AppConfig.katello?
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
      Candlepin::Pool.stub!(:get) do |x|
        {
          :productName => "Blah Server OS",
          :startDate => dates[x]
        }
      end
      @system = System.new(:name => "test", :cp_type => "system", :facts => {"distribution.name"=>"Fedora"})
      dates.each_pair do |k,v|
        pool = KTPool.create!(:cp_id => k)
        @akey.key_pools.create!(:pool_id  => pool.id, :allocated => 2)
      end
    end

    describe "entitlement out of one" do
      let(:dates) do
        {
          "a" => "2011-02-11T11:11:11.111+0000",
        }
      end

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "a", 2)
        @akey.pools.size.should == 1
        @akey.subscribe_system(@system)
      end
    end

    describe "entitlement with most recent date out of two" do
      let(:dates) do
        {
          "a" => "2011-02-11T11:11:11.111+0000",
          "b" => "2011-03-11T11:11:11.111+0000",
        }
      end

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "b", 2)
        @akey.pools.size.should == 2
        @akey.subscribe_system(@system)
      end
    end

    describe "entitlement with most recent date out of three" do
      let(:dates) do
        {
          "a" => "2011-02-11T11:11:11.111+0000",
          "b" => "2011-03-11T11:11:11.111+0000",
          "c" => "2011-01-11T11:11:11.111+0000",
        }
      end

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "b", 2)
        @akey.pools.size.should == 3
        @akey.subscribe_system(@system)
      end
    end

    describe "entitlement with least number available out of three" do
      let(:dates) do
        {
          "a" => "2011-01-11T11:11:11.111+0000",
          "b" => "2011-01-11T11:11:11.111+0000",
          "c" => "2011-01-11T11:11:11.111+0000",
        }
      end

      it "consumes the correct entitlement" do
        Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "a", 2)
        @akey.pools.size.should == 3
        @akey.subscribe_system(@system)
      end
    end

  end

end
