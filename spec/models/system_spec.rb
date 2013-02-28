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
require 'helpers/system_test_data'
include OrchestrationHelper
include SystemHelperMethods

describe System do

  include AuthorizationHelperMethods

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
  let(:installed_products) { [{"productId"=>"69", "productName"=>"Red Hat Enterprise Linux Server"}] }

  before(:each) do
    disable_org_orchestration

    @organization = Organization.create!(:name=>'test_org', :label=> 'test_org')
    @environment = KTEnvironment.create!(:name=>'test', :label=> 'test', :prior => @organization.library.id, :organization => @organization)
    @organization.reload #reload to get environment info

    @system = System.new(:name => system_name,
                         :environment => @environment,
                         :cp_type => cp_type,
                         :facts => facts,
                         :description => description,
                         :uuid => uuid,
                         :installedProducts => installed_products,
                         :serviceLevel => nil)

    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)

    Runcible::Extensions::Consumer.stub!(:create).and_return({:id => uuid})
  end

  context "system in invalid state should not be valid" do
    before(:each) { @system = System.new }
    specify { System.new(:name => 'name', :environment => @organization.environments.first, :cp_type => cp_type).should_not be_valid }
    specify { System.new(:name => 'name', :environment => @organization.environments.first, :facts => facts).should_not be_valid }
    specify { System.new(:cp_type => cp_type, :environment => @organization.environments.first, :facts => facts).should_not be_valid }
    specify { System.new(:name => system_name, :environment => @organization.library, :cp_type => cp_type, :facts => facts).should_not be_valid }
  end

  it "registers system in candlepin and pulp on create" do
    Resources::Candlepin::Consumer.should_receive(:create).once.with(@environment.id, @organization.name, system_name, cp_type, facts, installed_products, nil, nil, nil).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Runcible::Extensions::Consumer.should_receive(:create).once.with(uuid, {:display_name => system_name}).and_return({:id => uuid}) if Katello.config.katello?
    @system.save!
  end

  it "adds custom info if organization has default custom info set" do
    CustomInfo.skip_callback(:save, :after, :reindex_informable)
    CustomInfo.skip_callback(:destroy, :after, :reindex_informable)

    o = Organization.find(@organization.id)
    o.system_info_keys << "test_key"
    o.save!
    e = KTEnvironment.create!(:name=>'test2', :label=> 'test2', :prior => o.library.id, :organization => o)

    s = System.new(:name => system_name,
        :environment => e,
        :cp_type => cp_type,
        :facts => facts,
        :description => description,
        :uuid => uuid,
        :installedProducts => installed_products,
        :serviceLevel => nil)

    s.save!

    System.find(s.id).custom_info.size.should == 1
    System.find(s.id).custom_info.find_by_keyname("test_key").keyname.should == "test_key"
  end

  context "delete system" do
    before(:each) {
      @system.save!
    }

    it "should delete consumer in candlepin and pulp" do
      Resources::Candlepin::Consumer.should_receive(:destroy).once.with(uuid).and_return(true)
      Runcible::Extensions::Consumer.should_receive(:delete).once.with(uuid).and_return(true) if Katello.config.katello?
      @system.destroy
    end
  end

  context "regenerate identity certificates" do
    before { @system.uuid = uuid }

    it "should call Resources::Candlepin::Consumer.regenerate_identity_certificates" do
      Resources::Candlepin::Consumer.should_receive(:regenerate_identity_certificates).once.with(uuid).and_return(true)
      @system.regenerate_identity_certificates
    end
  end

  context "subscribe an entitlement" do
    before { @system.uuid = uuid }

    it "should call Resources::Candlepin::Consumer.consume_entitlement" do
      pool_id = "foo"
      Resources::Candlepin::Consumer.should_receive(:consume_entitlement).once.with(uuid,pool_id,nil).and_return(true)
      @system.subscribe pool_id
    end
  end

  context "unsubscribe an entitlement" do
    before { @system.uuid = uuid }
    entitlement_id = "foo"
    it "should call Resources::Candlepin::Consumer.remove_entitlement" do
      Resources::Candlepin::Consumer.should_receive(:remove_entitlement).once.with(uuid, entitlement_id).and_return(true)
      @system.unsubscribe entitlement_id
    end
  end

  context "unsubscribe an certificate by serial" do
    before { @system.uuid = uuid }

    it "should call Resources::Candlepin::Consumer.remove_certificate" do
      serial_id = "foo"
      Resources::Candlepin::Consumer.should_receive(:remove_certificate).once.with(uuid,serial_id).and_return(true)
      @system.unsubscribe_by_serial serial_id
    end
  end

  context "unsubscribe all entitlements" do
    before { @system.uuid = uuid }

    it "should call Resources::Candlepin::Consumer.remove_entitlements" do
      Resources::Candlepin::Consumer.should_receive(:remove_entitlements).once.with(uuid).and_return(true)
      @system.unsubscribe_all
    end
  end

  context "update system" do
    before(:each) do
      @system.save!
    end

    it "should give facts to Resources::Candlepin::Consumer" do
      @system.facts = facts
      @system.installedProducts = nil # simulate it's not loaded in memory
      Resources::Candlepin::Consumer.should_receive(:update).once.with(uuid, facts, nil, nil, nil, nil, nil, anything).and_return(true)
      @system.save!
    end

    it "should give installeProducts to Resources::Candlepin::Consumer" do
      @system.installedProducts = installed_products
      @system.facts = nil # simulate it's not loaded in memory
      Resources::Candlepin::Consumer.should_receive(:update).once.with(uuid, nil, nil, installed_products, nil, nil, nil, anything).and_return(true)
      @system.save!
    end

    it "should fail if the content view is not in the enviornment" do
      content_view = FactoryGirl.build_stubbed(:content_view)
      @system.stub(:content_view_id).and_return(content_view.id)
      ContentView.stub(:find).and_return(content_view)
      content_view.stub(:in_environment?).and_return(false)
      @system.save.should be_false
      expect { @system.save! }.to raise_exception(/Content view.*is not in environment/)
    end
  end

  context "persisted system has correct attributes" do
    before(:each) {
      @count = System.count
      @system.save! }

    specify { System.count.should == @count + 1 }
    specify { System.find(@system.id).name == system_name }
    specify { System.find(@system.id).uuid.should == uuid }
    specify {
      System.find(@system.id).organization.id.should == @organization.id }
  end

  context "cp attributes" do
    context "in persisted object" do
      before(:each) do
        @system.uuid = uuid
        @system.save
        Resources::Candlepin::Consumer.stub!(:get).and_return({:href => href, :uuid => uuid})
        Resources::Candlepin::Consumer.stub!(:entitlements).and_return({})
        Resources::Candlepin::Consumer.stub!(:available_pools).and_return([])
      end

      it "should access candlepin if uninialized" do
        Resources::Candlepin::Consumer.should_receive(:get).once.with(uuid).and_return({:href => href, :uuid => uuid})
        @system.href
      end

      specify { @system.href.should == href }
      specify { @system.uuid.should == uuid }
      specify { @system.cp_type.should == cp_type }

      it "should access candlepin if entitlements is uninialized" do
        Resources::Candlepin::Consumer.should_receive(:entitlements).once.with(uuid).and_return({})
        @system.entitlements
      end

      context "shouldn't access candlepin if initialized" do
        before(:each) do
          @system.href = href
          @system.entitlements = entitlements
          @system.save

          Resources::Candlepin::Consumer.should_not_receive(:get)
          Resources::Candlepin::Consumer.should_not_receive(:entitlements)
        end

        specify { @system.href.should == href; }
        specify { @system.entitlements.should == entitlements; }
      end

      it "should access candlepin if pools is uninialized" do
        Resources::Candlepin::Consumer.should_receive(:entitlements).once.with(uuid).and_return([{"pool" => {"id" => 100}}])
        Resources::Candlepin::Pool.should_receive(:find).once.and_return({})
        @system.pools
      end

      context "shouldn't access candlepin pools if initialized" do
        before(:each) do
          @system.href = href
          @system.pools = {}
          Resources::Candlepin::Consumer.should_not_receive(:get)
          Resources::Candlepin::Consumer.should_not_receive(:entitlements)
          Resources::Candlepin::Pool.should_not_receive(:find)
        end

        specify { @system.href.should == href }
        specify { @system.pools.should == pools }
      end

      it "should access candlepin if available_pools is uninitialized" do
        Resources::Candlepin::Consumer.should_receive(:available_pools).once.with(uuid, false).and_return([])
        @system.available_pools
      end

      context "shouldn't access candlepin available_pools if initialized" do
        before(:each) do
          @system.available_pools = available_pools
          Resources::Candlepin::Consumer.should_not_receive(:get)
          Resources::Candlepin::Consumer.should_not_receive(:available_pools)
        end
        specify { @system.available_pools.should == available_pools }
      end

    end

    context "shouldn't access candlepin if new record" do
      before(:each) { Resources::Candlepin::Consumer.should_not_receive(:get) }
      specify { @system.href.should be_nil }
    end
  end

  context "pulp attributes", :katello => true do
    it "should update package-profile" do
      Runcible::Extensions::Consumer.should_receive(:upload_profile).once.with(uuid, 'rpm', package_profile).and_return(true)
      @system.upload_package_profile(package_profile)
    end
  end

  describe "available releases" do
    before do
      disable_product_orchestration
      disable_repo_orchestration
      @product = Product.create!(:name=>"prod1", :label=> "prod1", :cp_id => '12345', :provider => @organization.redhat_provider, :environments => [@organization.library])
      @environment = KTEnvironment.create!({:name=>"Dev", :label=> "Dev", :prior => @organization.library, :organization => @organization}) do |e|
        e.products << @product
      end
      if Katello.config.katello?
        env_product = @product.environment_products.where(:environment_id => @environment.id).first
      else
        env_product = @product.environment_products.where(:environment_id => @organization.library.id).first
      end
      @releases = %w[6.1 6.2 6Server]
      @releases.each do |release|
        Repository.create!(:name => "Repo #{release}",
                          :label => "Repo#{release.gsub(".", "_")}",
                          :pulp_id => "repo #{release}",
                          :enabled => true,
                          :environment_product_id => env_product.id,
                          :major => "6",
                          :minor => release,
                          :cp_label => "repo",
                          :relative_path=>'/foo',
                          :content_id=>'foo',
                          :content_view_version=>env_product.environment.default_view_version,
                          :feed => 'https://localhost')
      end
      Repository.create!(:name => "Repo without releases",
                         :label => "Repo_without_releases",
                         :pulp_id => "repo_without_release",
                         :enabled => true,
                         :environment_product_id => env_product.id,
                         :major => nil,
                         :minor => nil,
                         :cp_label => "repo",
                         :relative_path=>'/foo',
                         :content_id=>'foo',
                         :content_view_version=>env_product.environment.default_view_version,
                         :feed => 'https://localhost')
      @system.environment = @environment
      @system.save!
    end

    it "returns all releases available for the current environment" do
      x = @system.available_releases
      @system.available_releases.should == @releases.sort
    end
  end


  describe "find system by a pool id" do
    let(:pool_id_1) {"POOL_ID_123"}
    let(:pool_id_2) {"POOL_ID_456"}
    let(:pool_id_3) {"POOL_ID_789"}
    let(:common_attrs) {
      {:environment => @environment,
       :cp_type => cp_type,
       :facts => facts}
    }

    before :each do

      @system_1 = create_system(common_attrs.merge(:name => "sys_1", :uuid => "sys_1_uuid"))
      @system_2 = create_system(common_attrs.merge(:name => "sys_2", :uuid => "sys_2_uuid"))
      @system_3 = create_system(common_attrs.merge(:name => "sys_3", :uuid => "sys_3_uuid"))

      Resources::Candlepin::Entitlement.stub(:get).and_return([
        {"pool" => {"id" => pool_id_1}, "consumer" => {"uuid" => @system_1.uuid}},
        {"pool" => {"id" => pool_id_1}, "consumer" => {"uuid" => @system_2.uuid}},
        {"pool" => {"id" => pool_id_2}, "consumer" => {"uuid" => @system_2.uuid}},
        {"pool" => {"id" => pool_id_2}, "consumer" => {"uuid" => @system_3.uuid}}
      ])
    end

    it "should find all systems that are subscribed to the pool" do
      pool_uuids = System.all_by_pool(pool_id_1).map{ |sys| sys.uuid}
      pool_uuids.should == [@system_1.uuid, @system_2.uuid]
    end

    it "should return empty array if the system isn't subscribed to that pool" do
      System.all_by_pool(pool_id_3).should == []
    end

  end

  describe "host-guest relation" do

    # TODO: Unsure how to test this after making :host, :guests use lazy_accessor
    pending "guest system" do
      before { Resources::Candlepin::Consumer.stub(:host => nil, :guests => []) }

      it "should get host system" do
        Resources::Candlepin::Consumer.should_receive(:host).with(@system.uuid).and_return(SystemTestData.host)
        @system.host.name.should == SystemTestData.host["name"]
      end
    end

    # TODO: Unsure how to test this after making :host, :guests use lazy_accessor
    pending "host system" do
      before { Resources::Candlepin::Consumer.stub(:host => nil, :guests => []) }

      it "should get guest systems" do
        Resources::Candlepin::Consumer.should_receive(:guests).with(@system.uuid).and_return(SystemTestData.guests)
        guests = @system.guests
        guests.should have(1).system
        guests.first.name.should == SystemTestData.guests.first["name"]
      end
    end

    context "guest without host (before running virt-who)" do
      it "should return no host" do
        Resources::Candlepin::CandlepinResource.stub(:default_headers => {}, :get => MemoStruct.new(:code => 204, :body => ""))
        @system.host.should_not be
      end
    end

  end


  describe "a user with no permissions" do
    before :each do
      #give access to the org
      User.current =  user_with_permissions{ |u| u.can(:create, :providers, nil, @organization) }
    end

    it "Should not be able to do anything with systems" do
      System.readable(@organization).should_not include(@system)
      System.any_readable?(@organization).should == false
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == false
      @system.editable?.should == false
      @system.deletable?.should == false
    end
  end


  describe "a user with environment system perms" do
    before :each do
      @system.save!
    end

    it "should be readable if user can read systems for environment" do
      User.current =  user_with_permissions { |u| u.can(:read_systems, :environments, @environment.id, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == false
    end

    it "should be editable if user can edit systems for environment" do
      User.current =  user_with_permissions { |u| u.can(:update_systems, :environments, @environment.id, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == true
      @system.deletable?.should == false
    end

    it "should be registerable if user can edit systems for environment" do
      User.current =  user_with_permissions { |u| u.can(:register_systems, :environments, @environment.id, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == true
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == false
    end

    it "should be deletable if user can delete systems for environment" do
      User.current =  user_with_permissions { |u| u.can(:delete_systems, :environments, @environment.id, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == true
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == true
    end


  end

  describe "a user with organization system perms " do
    before :each do
      @system.save!
    end

    it "should be readable if user can read systems for organization" do
      User.current =  user_with_permissions { |u| u.can(:read_systems, :organizations, nil, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == false
    end

    it "should be editable if user can edit systems for organization" do
      User.current =  user_with_permissions { |u| u.can(:update_systems, :organizations, nil, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == true
      @system.deletable?.should == false
    end

    it "should be registerable if user can edit systems for organization" do
      User.current =  user_with_permissions { |u| u.can(:register_systems, :organizations, nil, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == true
      System.registerable?(nil, @organization).should == true
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == false
    end

    it "should be deletable if user can delete systems for organization" do
      User.current =  user_with_permissions { |u| u.can(:delete_systems, :organizations, nil, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == true
      System.any_deletable?(nil, @organization).should == true
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == true
    end

  end

  describe "a user with random system permissions in headpin mode" do
    before (:each) do
      @system.save!
      Katello.config.stub!(:katello?).and_return(false)
    end

    it "should be deletable" do
      User.current =  user_with_permissions { |u| u.can(:delete_systems, :organizations, nil, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == true
      System.any_deletable?(nil, @organization).should == true
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == true
    end

    it "should be editable" do
      User.current =  user_with_permissions { |u| u.can(:update_systems, :organizations, nil, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == true
      @system.deletable?.should == false
    end

    it "should be registerable" do
      User.current =  user_with_permissions { |u| u.can(:register_systems, :organizations, nil, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == true
      System.registerable?(nil, @organization).should == true
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == false
    end
  end

  describe "a user with organization system perms " do
    before :each do
      disable_consumer_group_orchestration
      @group = SystemGroup.create!(:organization=>@organization, :name=>"test_group")
      @system.system_groups << @group
      @system.save!
    end

    it "should be readable if user can read systems for organization" do
      User.current =  user_with_permissions { |u| u.can(:read_systems, :system_groups, @group.id, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == false
    end

    it "should be editable if user can edit systems for organization" do
      User.current =  user_with_permissions { |u| u.can(:update_systems, :system_groups, @group.id, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == false
      System.any_deletable?(nil, @organization).should == false
      @system.readable?.should == true
      @system.editable?.should == true
      @system.deletable?.should == false
    end

    it "should be deletable if user can delete systems for organization" do
      User.current =  user_with_permissions { |u| u.can(:delete_systems, :system_groups, @group.id, @organization) }
      System.readable(@organization).should include(@system)
      System.any_readable?(@organization).should == true
      System.registerable?(@environment, @organization).should == false
      System.registerable?(nil, @organization).should == false
      System.any_deletable?(@environment, @organization).should == true
      System.any_deletable?(nil, @organization).should == true
      @system.readable?.should == true
      @system.editable?.should == false
      @system.deletable?.should == true
    end


  end

end
