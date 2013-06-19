#o
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
include OrchestrationHelper
include SystemHelperMethods

describe ActivationKey do
  include AuthorizationHelperMethods

  let(:aname) { 'myactkey' }
  let(:adesc) { 'my activation key description' }

  before(:each) do
    disable_org_orchestration
    disable_consumer_group_orchestration
    disable_product_orchestration

    @organization = Organization.create!(:name=>'test_org', :label=> 'test_org')
    @environment_1 = KTEnvironment.create!(:name=>'dev', :label=> 'dev', :prior => @organization.library.id, :organization => @organization)
    @environment_2 = KTEnvironment.create!(:name=>'test', :label=> 'test', :prior => @environment_1.id, :organization => @organization)
    @akey = ActivationKey.create!(:name => aname, :description => adesc, :organization => @organization,
                                  :environment_id => @environment_1.id)
  end

  context "in valid state" do
    it "should be valid if the environment is Library" do
      @akey.name = 'valid key'
      @akey.environment_id = @organization.library.id
      @akey.should be_valid
      @akey.errors[:base].should be_empty
    end
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

    it "should be invalid if environment in another org is specified" do
      org_2 = Organization.create!(:name=>'test_org2', :label=> 'test_org2')
      env_1_org2 = KTEnvironment.create!(:name=>'dev', :label=> 'dev', :prior => org_2.library.id, :organization => org_2)
      @akey.name = 'invalid key'
      @akey.organization=@organization
      @akey.environment = env_1_org2
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
  end

  describe "adding systems groups" do
    before(:each) do
      @group = SystemGroup.create!(:name=>"TestSystemGroup", :organization=>@organization)
    end

    it "should add groups" do
      @akey.system_groups << @group
      @akey.save!
      ActivationKey.find(@akey.id).system_groups.should include @group
    end

    it "Should not allow groups to be added that conflict with the environment" do
      @group.environments = [@environment_2]
      @group.save!
      lambda{@akey.system_groups << @group
             @akey.save!}.should raise_exception
    end
  end



  describe "pools in a activation key" do
    before(:each) do
      disable_pools_orchestration
    end

    it "should map 2way pool to keys" do
      s = ::Pool.create!(:cp_id  => 'abc123')
      @akey.pools = [s]
      @akey.pools.first.cp_id.should == 'abc123'
      s.activation_keys.first.name.should == aname
    end

    it "should assign multiple pools to keys" do
      s = ::Pool.create!(:cp_id  => 'abc123')
      s2 = ::Pool.create!(:cp_id  => 'def123')
      @akey.pools = [s,s2]
      @akey.pools.last.cp_id.should == 'def123'
    end

    it "should include pools details in json output" do
      User.current = user_without_permissions
      Resources::Candlepin::Pool.stub!(:find).and_return({'productName' => 'p123'})
      pool = ::Pool.create!(:cp_id  => 'abc123')
      @akey.pools << pool
      pool.reload
      @akey.as_json[:pools].first.should include(:cp_id => pool.cp_id, 'productName' => 'p123')
    end
  end

  describe "#apply_to_system" do

    before(:each) do
      Runcible::Extensions::Consumer.stub!(:create).and_return({:id => "1234"}) if Katello.config.katello?
      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => "1234", :owner => {:key => "1234"}})
      @system = System.new(:name => "test", :cp_type => "system", :facts => {"distribution.name"=>"Fedora"})
      @system2 = System.new(:name => "test2", :cp_type => "system", :facts => {"distribution.name"=>"Fedora"})
      @akey_limit1 = ActivationKey.create!(:name => "usage_limit_key1", :usage_limit => 1, :organization => @organization, :environment => @environment_1)
    end

    it "assignes environment to the system" do
      @akey.apply_to_system(@system)
      @system.environment.should == @akey.environment
    end

    it "creates an association between the activation key and the system" do
      @akey.apply_to_system(@system)
      @system.save!
      @system.activation_keys.should include(@akey)
    end

    it "apply once for limit 1" do
      @akey_limit1.apply_to_system(@system)
      @system.save!
      @system.activation_keys.should include(@akey_limit1)
    end

    it "not apply twice for limit 1" do
      @akey_limit1.apply_to_system(@system)
      @system.save!
      @system.activation_keys.should include(@akey_limit1)
      lambda {
        @akey_limit1.apply_to_system(@system2)
      }.should raise_exception
    end

  end

  describe "#subscribe_system" do

    before(:each) do
      Resources::Candlepin::Pool.stub!(:find) do |x|
        {
          :productName => "Blah Server OS",
          :productId => dates[x][:productId],
          :startDate => dates[x][:startDate],
          :quantity => dates[x][:quantity],
          :consumed => dates[x][:consumed],
          :productAttributes => [{:name => "sockets", :value => (dates[x][:sockets] || 1)}]
        }.with_indifferent_access
      end
      @system = System.new(:name => "test", :cp_type => "system", :facts => {"distribution.name"=>"Fedora"}, :uuid => "uuid-uuid")
      @system.should_receive(:sockets).and_return(sockets)
      dates.each do |k,v|
        unless Product.find_by_cp_id(v[:productId], @organization)
          product = @organization.redhat_provider.products.create!(:label =>"blah", :cp_id => v[:productId], :name => "Blah Server OS #{v[:productId]}")
          # overwrite the cp_id from orchestration
          product.update_attributes!(:cp_id => v[:productId])
        end
        pool = ::Pool.create!(:cp_id => k)
        @akey.key_pools.create!(:pool_id  => pool.id)
      end
      Resources::Candlepin::Consumer.stub(:consume_entitlement)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "a", 1)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "b", 1)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "a", 1)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 1)
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 1)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 5)
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 3)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 1)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 1)
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
        lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough pools/)
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
        lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough pools/)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 2)
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
        lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough pools/)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 2).and_return([ { "id" => "ent1" } ])
        Resources::Candlepin::Consumer.should_receive(:remove_entitlement).with(@system.uuid, "ent1")
        lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough pools/)
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
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 1)
        Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 1)
        @akey.subscribe_system(@system)
      end
    end

    # see https://fedorahosted.org/katello/wiki/ActivationKeysDesign for more info
    context "multi-socket pools" do

      describe "consume 2 entitlements in S2 (0-2)" do
        let(:dates) do
          {
            "pool 1" => {
              :productId => "product 1",
              :startDate => "2011-01-01T00:00:00.000+0000", # same date
              :quantity => 5,
              :consumed => 5,
            },
            "pool 2" => {
              :productId => "product 1",
              :startDate => "2011-01-01T00:00:00.000+0000", # same date
              :quantity => 5, # 2 remaining
              :consumed => 3,
              :sockets => 2
            },
          }
        end
        let(:sockets) { 3 }

        it "consumes the correct entitlement" do
          Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 2)
          @akey.subscribe_system(@system)
        end

        describe "consume 2 entitlements in S2 (1-1)" do
          let(:dates) do
            {
              "pool 1" => {
                :productId => "product 1",
                :startDate => "2011-01-01T00:00:00.000+0000", # same date
                :quantity => 5, # 1 remaining
                :consumed => 4,
                :sockets => 2,
              },
              "pool 2" => {
                :productId => "product 1",
                :startDate => "2011-01-01T00:00:00.000+0000", # same date
                :quantity => 5, # 1 remaining
                :consumed => 4,
                :sockets => 2,
              },
            }
          end
          let(:sockets) { 4 }

          it "consumes the correct entitlement" do
            Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 1", 1)
            Resources::Candlepin::Consumer.should_receive(:consume_entitlement).with(@system.uuid, "pool 2", 1)
            @akey.subscribe_system(@system)
          end
        end

        describe "not enough entitlements in two pools" do
          let(:dates) do
            {
              "pool 1" => {
                :productId => "product 1",
                :startDate => "2011-01-01T00:00:00.000+0000", # older
                :quantity => 2,
                :consumed => 0,
                :sockets => 3,
              },
              "pool 2" => {
                :productId => "product 1",
                :startDate => "2011-01-02T00:00:00.000+0000",
                :quantity => 2, # 1 remaining
                :consumed => 1,
                :sockets => 3,

              },
            }
          end
          let(:sockets) { 10 }

          it "should not consume anything and report error" do
            Resources::Candlepin::Consumer.should_not_receive(:consume_entitlement)
            lambda { @akey.subscribe_system(@system) }.should raise_error(RuntimeError, /^Not enough pools/)
          end
        end
      end
    end
  end
end
