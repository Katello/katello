#o
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "katello_test_helper"

module Katello
  describe ActivationKey do
    include OrchestrationHelper
    include SystemHelperMethods

    let(:aname) { 'myactkey' }
    let(:adesc) { 'my activation key description' }

    before(:each) do
      disable_org_orchestration
      disable_consumer_group_orchestration
      disable_product_orchestration
      disable_activation_key_orchestration

      @organization = get_organization
      @environment_1 = katello_environments(:dev)
      @environment_2 = katello_environments(:staging)
      @akey = ActivationKey.create(:name => aname, :description => adesc, :organization => @organization,
                                   :environment_id => @environment_1.id, :unlimited_content_hosts => false,
                                   :max_content_hosts => 1)
    end

    describe "in valid state" do
      it "should be valid if the environment is Library" do
        @akey.name = 'valid key'
        @akey.environment_id = @organization.library.id
        @akey.content_view_id = @organization.library.content_views.first.id
        @akey.must_be :valid?
        @akey.errors[:base].must_be_empty
      end
    end

    describe "in invalid state" do
      before { @akey = ActivationKey.new }

      it "should be invalid without name" do
        @akey.wont_be :valid?
        @akey.errors[:name].wont_be_empty
      end

      it "should be invalid without default environment" do
        @akey.name = 'invalid key'
        @akey.must_be :valid?
        @akey.errors[:base].must_be_empty
      end

      it "should be invalid if non-existent environment is specified" do
        @akey.name = 'invalid key'
        @akey.environment_id = 123_456

        @akey.wont_be :valid?
        @akey.errors[:environment].wont_be_empty
      end

      it "should be invalid if environment in another org is specified" do
        org_2 = get_organization(:organization2)
        #Organization.create!(:name=>'test_org2', :label=> 'test_org2')
        env_1_org2 = KTEnvironment.create(:name => 'dev', :label => 'dev', :prior => org_2.library.id, :organization => org_2)
        @akey.name = 'invalid key'
        @akey.organization = @organization
        @akey.environment = env_1_org2
        @akey.wont_be :valid?
        @akey.errors[:environment].wont_be_empty
      end
    end

    it "should be able to create" do
      @akey.wont_be :nil?
    end

    describe "should be able to update" do
      it "name" do
        a = ActivationKey.find_by_name(aname)
        a.wont_be :nil?
        new_name = a.name + "N"
        b = ActivationKey.update(a.id, :name => new_name)
        b.name.must_equal new_name
      end

      it "description" do
        a = ActivationKey.find_by_name(aname)
        a.wont_be :nil?
        new_description = a.description + "N"
        b = ActivationKey.update(a.id, :description => new_description)
        b.description.must_equal new_description
      end

      it "environment" do
        a = ActivationKey.find_by_name(aname)
        a.wont_be :nil?
        b = ActivationKey.update(a.id, :environment => @environment_2)
        b.environment.must_equal @environment_2
      end
    end

    describe "adding host collections" do
      before(:each) do
        @host_collection = HostCollection.create!(:name => "TestHostCollection", :organization => @organization)
      end

      it "should add host collections" do
        @akey.host_collections << @host_collection
        @akey.save!
        ActivationKey.find(@akey.id).host_collections.must_include @host_collection
      end
    end

    describe "#apply_to_system" do
      before(:each) do
        Katello.pulp_server.extensions.consumer.stubs(:create).returns(:id => "1234")
        Resources::Candlepin::Consumer.stubs(:create).returns(:uuid => "1234", :owner => {:key => "1234"})
        @system = System.new(:name => "test", :cp_type => "system", :facts => {"distribution.name" => "Fedora"})
        @system2 = System.new(:name => "test2", :cp_type => "system", :facts => {"distribution.name" => "Fedora"})
        @akey_limit1 = ActivationKey.create(:name => "max_content_hosts_key1", :max_content_hosts => 1, :unlimited_content_hosts => false,
                                            :organization => @organization, :environment => @environment_1)
      end

      it "assignes environment to the system" do
        @akey.apply_to_system(@system)
        @system.environment.must_equal @akey.environment
      end

      it "creates an association between the activation key and the system" do
        @akey.apply_to_system(@system)
        @system.save!
        @system.activation_keys.must_include(@akey)
      end

      it "apply once for limit 1" do
        @akey_limit1.apply_to_system(@system)
        @system.save!
        @system.activation_keys.must_include(@akey_limit1)
      end

      it "not apply twice for limit 1" do
        @akey_limit1.apply_to_system(@system)
        @system.save!
        @system.activation_keys.must_include(@akey_limit1)
        apply_limit = lambda do
          @akey_limit1.apply_to_system(@system2)
        end
        apply_limit.must_raise Katello::Errors::MaxContentHostsReachedException
      end
    end
  end
end
