#
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

require 'katello_test_helper'
require 'helpers/system_test_data'

module Katello
  describe System do

    include OrchestrationHelper
    include OrganizationHelperMethods
    include SystemHelperMethods

    let(:facts) { {"distribution.name" => "Fedora"} }
    let(:system_name) { 'testing' }
    let(:cp_type) { 'system' }
    let(:uuid) { '1234' }
    let(:href) { '/blah' }
    let(:entitlements) { {} }
    let(:pools) { {} }
    let(:available_pools) { {} }
    let(:description) { 'description' }
    let(:package_profile) do
      [{"epoch" => 0, "name" => "im-chooser", "arch" => "x86_64", "version" => "1.4.0", "vendor" => "Fedora Project", "release" => "1.fc14"},
       {"epoch" => 0, "name" => "maven-enforcer-api", "arch" => "noarch", "version" => "1.0", "vendor" => "Fedora Project", "release" => "0.1.b2.fc14"},
       {"epoch" => 0, "name" => "ppp", "arch" => "x86_64", "version" => "2.4.5", "vendor" => "Fedora Project", "release" => "12.fc14"},
       {"epoch" => 0, "name" => "pulseaudio-module-bluetooth", "arch" => "x86_64", "version" => "0.9.21", "vendor" => "Fedora Project", "release" => "7.fc14"},
       {"epoch" => 0, "name" => "dbus-cxx-glibmm", "arch" => "x86_64", "version" => "0.7.0", "vendor" => "Fedora Project", "release" => "2.fc14.1"},
       {"epoch" => 0, "name" => "twolame-libs", "arch" => "x86_64", "version" => "0.3.12", "vendor" => "RPM Fusion", "release" => "4.fc11"},
       {"epoch" => 0, "name" => "gtk-vnc", "arch" => "x86_64", "version" => "0.4.2", "vendor" => "Fedora Project", "release" => "4.fc14"}]
    end
    let(:installed_products) { [{"productId" => "69", "productName" => "Red Hat Enterprise Linux Server"}] }

    before(:each) do
      disable_org_orchestration

      @organization = get_organization
      @environment = @organization.library

      @system = System.new(:name => system_name,
                           :environment => @environment,
                           :cp_type => cp_type,
                           :facts => facts,
                           :description => description,
                           :uuid => uuid,
                           :installedProducts => installed_products,
                           :serviceLevel => nil)

      Resources::Candlepin::Consumer.stubs(:create).returns(:uuid => uuid, :owner => {:key => uuid})
      Resources::Candlepin::Consumer.stubs(:update).returns(true)

      Katello.pulp_server.extensions.consumer.stubs(:create).returns(:id => uuid)
    end

    describe "system in valid state should be valid" do
      before(:each) { @system = System.new }
      specify { System.new(:name => system_name, :environment => @organization.library, :cp_type => cp_type, :facts => facts).must_be :valid? }
    end

    describe "system in invalid state should not be valid" do
      before(:each) { @system = System.new }
      specify { System.new(:name => 'name', :environment => @organization.kt_environments.first, :cp_type => cp_type).wont_be :valid? }
      specify { System.new(:name => 'name', :environment => @organization.kt_environments.first, :facts => facts).wont_be :valid? }
      specify { System.new(:cp_type => cp_type, :environment => @organization.kt_environments.first, :facts => facts).wont_be :valid? }
    end

    it "adds custom info if organization has default custom info set" do
      CustomInfo.skip_callback(:save, :after, :reindex_informable)
      CustomInfo.skip_callback(:destroy, :after, :reindex_informable)

      o = Organization.find(@organization.id)
      o.default_info["system"] << "test_key"
      o.save!
      #    e = create_environment(:name=>'test2', :label=> 'test2', :prior => o.library.id, :organization => o)

      s = System.new(:name => system_name,
                     :environment => o.library,
                     :cp_type => cp_type,
                     :facts => facts,
                     :description => description,
                     :uuid => uuid,
                     :installedProducts => installed_products,
                     :serviceLevel => nil)

      s.save!

      System.find(s.id).custom_info.size.must_equal(1)
      System.find(s.id).custom_info.find_by_keyname("test_key").keyname.must_equal("test_key")
    end

    describe "regenerate identity certificates" do
      before { @system.uuid = uuid }

      it "should call Resources::Candlepin::Consumer.regenerate_identity_certificates" do
        Resources::Candlepin::Consumer.expects(:regenerate_identity_certificates).once.with(uuid).returns(true)
        @system.regenerate_identity_certificates
      end
    end

    describe "subscribe an entitlement" do
      before { @system.uuid = uuid }

      it "should call Resources::Candlepin::Consumer.consume_entitlement" do
        pool_id = "foo"
        Resources::Candlepin::Consumer.expects(:consume_entitlement).once.with(uuid, pool_id, nil).returns(true)
        @system.subscribe pool_id
      end
    end

    describe "unsubscribe an entitlement" do
      before { @system.uuid = uuid }
      entitlement_id = "foo"
      it "should call Resources::Candlepin::Consumer.remove_entitlement" do
        Resources::Candlepin::Consumer.expects(:remove_entitlement).once.with(uuid, entitlement_id).returns(true)
        @system.unsubscribe entitlement_id
      end
    end

    describe "unsubscribe an certificate by serial" do
      before { @system.uuid = uuid }

      it "should call Resources::Candlepin::Consumer.remove_certificate" do
        serial_id = "foo"
        Resources::Candlepin::Consumer.expects(:remove_certificate).once.with(uuid, serial_id).returns(true)
        @system.unsubscribe_by_serial serial_id
      end
    end

    describe "unsubscribe all entitlements" do
      before { @system.uuid = uuid }

      it "should call Resources::Candlepin::Consumer.remove_entitlements" do
        Resources::Candlepin::Consumer.expects(:remove_entitlements).once.with(uuid).returns(true)
        @system.unsubscribe_all
      end
    end

    describe "update system" do
      before(:each) do
        @system.save!
      end

      it "should fail if the content view is not in the enviornment" do
        content_view = FactoryGirl.build_stubbed(:katello_content_view)
        @system.stubs(:content_view_id).returns(content_view.id)
        ContentView.stubs(:find).returns(content_view)
        content_view.stubs(:in_environment?).returns(false)
        @system.save.must_equal(false)
        lambda { @system.save! }.must_raise(ActiveRecord::RecordInvalid)
      end
    end

    describe "persisted system has correct attributes" do
      before(:each) do
        @count = System.count
        @system.save!
      end

      specify { System.count.must_equal(@count + 1) }
      specify { System.find(@system.id).name == system_name }
      specify { System.find(@system.id).uuid.must_equal(uuid) }
      specify do
        System.find(@system.id).organization.id.must_equal(@organization.id)
      end
    end

    describe "cp attributes" do
      describe "in persisted object" do
        before(:each) do
          @system.uuid = uuid
          @system.save
          Resources::Candlepin::Consumer.stubs(:get).returns(:href => href, :uuid => uuid)
          Resources::Candlepin::Consumer.stubs(:entitlements).returns({})
          Resources::Candlepin::Consumer.stubs(:available_pools).returns([])
        end

        it "should access candlepin if uninialized" do
          Resources::Candlepin::Consumer.expects(:get).once.with(uuid).returns(:href => href, :uuid => uuid)
          @system.href
        end

        it "href dude" do
          @system.href.must_equal(href)
        end

        it "uuid bro" do
          @system.uuid.must_equal(uuid)
        end

        it "cp_type srsly" do
          @system.cp_type.must_equal(cp_type)
        end

        it "should access candlepin if entitlements is uninialized" do
          Resources::Candlepin::Consumer.expects(:entitlements).once.with(uuid).returns({})
          @system.entitlements
        end

        describe "shouldn't access candlepin if initialized" do
          before(:each) do
            @system.href = href
            @system.entitlements = entitlements
            @system.save

            Resources::Candlepin::Consumer.expects(:get).never
            Resources::Candlepin::Consumer.expects(:entitlements).never
          end

          specify { @system.href.must_equal(href) }
          specify { @system.entitlements.must_equal(entitlements) }
        end

        it "should access candlepin if pools is uninialized" do
          Resources::Candlepin::Consumer.expects(:entitlements).once.with(uuid).returns([{"pool" => {"id" => 100}}])
          Resources::Candlepin::Pool.expects(:find).once.returns({})
          @system.pools
        end

        describe "shouldn't access candlepin pools if initialized" do
          before(:each) do
            @system.href = href
            @system.pools = {}
            Resources::Candlepin::Consumer.expects(:get).never
            Resources::Candlepin::Consumer.expects(:entitlements).never
            Resources::Candlepin::Pool.expects(:find).never
          end

          specify { @system.href.must_equal(href) }
          specify { @system.pools.must_equal(pools) }
        end

        it "should access candlepin if available_pools is uninitialized" do
          Resources::Candlepin::Consumer.expects(:available_pools).once.with(uuid, false).returns([])
          @system.available_pools
        end

        describe "shouldn't access candlepin available_pools if initialized" do
          before(:each) do
            @system.available_pools = available_pools
            Resources::Candlepin::Consumer.expects(:get).never
            Resources::Candlepin::Consumer.expects(:available_pools).never
          end
          specify { @system.available_pools.must_equal(available_pools) }
        end

      end

      describe "shouldn't access candlepin if new record" do
        before(:each) { Resources::Candlepin::Consumer.expects(:get).never }
        specify { @system.href.must_be_nil }
      end
    end

    describe "pulp attributes (katello)" do
      it "should update package-profile" do
        Katello.pulp_server.extensions.consumer.expects(:upload_profile).once.with(uuid, 'rpm', package_profile).returns(true)
        System.any_instance.expects(:generate_applicability).once
        @system.upload_package_profile(package_profile)
      end
    end

    describe "find system by a pool id" do
      let(:pool_id_1) { "POOL_ID_123" }
      let(:pool_id_2) { "POOL_ID_456" }
      let(:pool_id_3) { "POOL_ID_789" }
      let(:common_attrs) do
        {:environment => @environment,
         :cp_type => cp_type,
         :facts => facts}
      end

      before :each do

        @system_1 = create_system(common_attrs.merge(:name => "sys_1", :uuid => "sys_1_uuid"))
        @system_2 = create_system(common_attrs.merge(:name => "sys_2", :uuid => "sys_2_uuid"))
        @system_3 = create_system(common_attrs.merge(:name => "sys_3", :uuid => "sys_3_uuid"))

        Resources::Candlepin::Entitlement.stubs(:get).returns([
          {"pool" => {"id" => pool_id_1}, "consumer" => {"uuid" => @system_1.uuid}},
          {"pool" => {"id" => pool_id_1}, "consumer" => {"uuid" => @system_2.uuid}},
          {"pool" => {"id" => pool_id_2}, "consumer" => {"uuid" => @system_2.uuid}},
          {"pool" => {"id" => pool_id_2}, "consumer" => {"uuid" => @system_3.uuid}}
        ])
      end

      it "should find all systems that are subscribed to the pool" do
        pool_uuids = System.all_by_pool(pool_id_1).map { |sys| sys.uuid }
        pool_uuids.must_equal([@system_1.uuid, @system_2.uuid])
      end

      it "should return empty array if the system isn't subscribed to that pool" do
        System.all_by_pool(pool_id_3).must_equal([])
      end

    end

    describe "host-guest relation" do

      describe "guest without host (before running virt-who)" do
        it "should return no host" do
          response = stub
          response.stubs(:code => 204, :body => "")
          Resources::Candlepin::CandlepinResource.stubs(:default_headers => {}, :get => response)
          @system.virtual_host.must_be_nil
        end
      end

    end

  end
end
