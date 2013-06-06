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
describe Permission do
  include OrchestrationHelper
  include AuthorizationHelperMethods

  def add_test_type type, verbs
    verb_hash = {}
    verbs.each{|v|
      verb_hash[v.to_s] = "description"

    }

    ResourceType::TYPES[type] = {:model =>
      OpenStruct.new(:no_tag_verbs => [], :verb_hash => verb_hash).tap do |os|
        def os.list_verbs(global=false); verb_hash; end
      end
    }

  end



  before(:each) do
    disable_user_orchestration

    @some_role = Role.find_or_create_by_name(:name => 'some_role')
    @repo_admin = Role.find_or_create_by_name(:name => 'repo_admin')
    @super_admin = Role.find_or_create_by_name(:name => 'super_admin')

    @magic_perm = Permission.create!(:role => @super_admin, :name => 'test1000',
                                :resource_type=> ResourceType.find_or_create_by_name(:all),
                                :all_tags => true, :all_verbs => true, :organization => nil)


    @god = User.find_or_create_by_username(
      :username => 'god',
      :password => "password",
      :email => 'god@somewhere.com',
      :roles => [ @super_admin ])

    @admin = User.find_or_create_by_username(
      :username => 'admin-custom',
      :password => "password",
      :email => 'admin@somewhere.com',
      :roles => [ @some_role ])
    @user_bob = User.find_or_create_by_username(
      :username => 'bob',
      :password => "password",
      :email => 'bob@somewhere.com',
      :roles => [ @repo_admin ])


    allow @some_role, [:create], :organizations
    allow @some_role, [:new], :organizations
    allow @some_role, [:test], :test1
    allow @some_role, [:test], :test2
    allow @some_role, [:test], :test3

    add_test_type :repogroup, ["create_repo"]
    add_test_type :repo, ["create_repo", "delete_repo"]
    add_test_type "repo-bad", ["create_repo", "delete_repo"]
    add_test_type :TestResourceType, ["magic_verb", "magic_verb_foo", "do_magic_verb"]
    add_test_type :TestResourceTypefoo, ["magic_verb", "magic_verb_foo", "do_magic_verb"]
    add_test_type :xxx, ["create"]

    @repogroup_internal = 1
    @repo_rhel6 = 2

    allow @repo_admin, :create_repo, :repogroup, @repogroup_internal
    allow @repo_admin, :delete_repo, :repo, [@repogroup_internal, @repo_rhel6]
  end

  it "should list tags properly" do
    ResourceType.all.collect{|t| t.name}.sort.should_not == nil
  end

  it "should list verbs properly" do
    Verb.verbs_for("repogroup").keys.should include  "create_repo"
  end

  context "super_admin" do
    it { @god.allowed_to?('create', 'organizations').should be_true }
    it { @god.allowed_to?('create', 'providers').should be_true if Katello.config.katello? }
  end

  context "some_role" do
    it { @admin.allowed_to?('create', 'organizations').should be_true }
    it { @admin.allowed_to?('delete', 'organizations').should be_false }
    it { @admin.allowed_to?('create', 'xxx').should be_false }
  end

  context "repo_admin" do
    it { @user_bob.allowed_to?('create', 'organizations').should be_false }
    it { @user_bob.allowed_to?("create_repo", "repogroup", @repogroup_internal).should be_true }
    it { @user_bob.allowed_to?("create_repo", "repogroup", 10**7).should be_true } #global implies all tags = true
    it { @user_bob.allowed_to?("create_repo", "repo-bad").should be_false }
    it { @user_bob.allowed_to?("delete_repo", "repo", [@repogroup_internal, @repo_rhel6]).should be_true }
    it { @user_bob.allowed_to?("delete_repo", "repo", [@repogroup_internal]).should be_true }
    it { @user_bob.allowed_to?("create_repo", "repogroup", @repogroup_internal).should be_true }
    it { @user_bob.allowed_to?("delete_repo", "repo", [@repogroup_internal]).should be_true }
  end

  context "global org tests" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
      add_test_type(:bar_resource_type, [:foo_verb])
    end
    describe "allow all resources  globally" do
      before do
         @magic_perm = Permission.create!(:role => @some_role, :all_verbs=> true, :name => 'test1000', :all_tags=> true,
                           :resource_type=> ResourceType.find_or_create_by_name(:all), :organization => nil)
      end
      specify {Permission.last.all_types?.should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, @organization).should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, nil).should be_true}
    end

    describe "allow all verbs" do
      before do
        @tag = 1
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :all_verbs => true, :tag_values =>[@tag],
                                      :resource_type=> @res_type)
      end
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name,nil, @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag, @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "foo", 10 ** 6).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "foo", 10 ** 6, @organization).should be_false}
    end

    describe "allow all tags" do
      before do
        @foo_tag=200
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :verbs => [@verb],
                                         :all_tags=> true,
                                      :resource_type=> @res_type)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,@foo_tag).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,@foo_tag, @organization).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",@foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",@foo_tag, @organization).should be_false}
      specify{@admin.allowed_to?(@verb_name + "_foo", @res_type_name,@foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name + "_foo", @res_type_name,@foo_tag, @organization).should be_false}
    end


    describe "regular perms" do
      before do
        @tag_name = 100
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :verbs => [@verb],
                                         :tag_values=> [@tag_name],
                                      :resource_type=> @res_type)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,[@tag_name]).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,[@tag_name], @organization).should be_true}
      #global implies all tags = true
      specify{@admin.allowed_to?(@verb_name, @res_type_name,[@tag_name + 11]).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",[@tag_name], @organization).should be_false}
    end

    describe "regular perms no tags" do
      before do
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :verbs => [@verb],
                                      :resource_type=> @res_type)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,nil).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,nil, @organization).should be_true}

      #global implies all tags = true
      specify{@admin.allowed_to?(@verb_name, @res_type_name,["1000"]).should be_true}
    end


  end

  context "non global org tests" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
      add_test_type :bar_resource_type, ["foo_verb"]
    end
    describe "allow all resources orgwise" do
      before do
         @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :all_tags=> true, :all_verbs=>true,
                         :resource_type=> ResourceType.find_or_create_by_name(:all), :organization => @organization)
      end
      specify {Permission.last.all_types?.should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, @organization).should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, nil).should be_false}
    end

    describe "allow all verbs" do
      before do
        @tag_name = 1000
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :all_verbs => true,:tag_values => [@tag_name],
                                      :resource_type=> @res_type, :organization => @organization)
      end
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, nil).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, nil, @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name, @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "foo", 1222).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "foo", 1222, @organization).should be_false}
    end

    describe "allow all tags" do
      before do
        @foo_tag = 1023
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :verbs => [@verb],
                                         :all_tags=> true,
                                      :resource_type=> @res_type, :organization => @organization)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,@foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,@foo_tag, @organization).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",@foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",@foo_tag, @organization).should be_false}
      specify{@admin.allowed_to?(@verb_name + "_foo", @res_type_name,@foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name + "_foo", @res_type_name,@foo_tag, @organization).should be_false}
    end


    describe "no_tag_verbs", :katello => true do
      before do
        @foo_tag = 0022
        @res_type_name = :providers
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @no_tag_verbs = Provider.no_tag_verbs
        @verb_name = @no_tag_verbs.first
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :verbs => [@verb],
                                      :resource_type=> @res_type, :organization => @organization)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,nil, @organization).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,@foo_tag, @organization).should be_true}

      specify{@admin.allowed_to?(@verb_name, @res_type_name,nil,nil).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,@foo_tag, nil).should be_false}
    end

  end


  context "org_id_create" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
      @res_type_name = "TestResourceType"
      @res_type = ResourceType.find_or_create_by_name(@res_type_name)
      @magic_perm = Permission.create!(:name => 'test1000', :role => @some_role, :all_verbs => true,
                                   :resource_type=> @res_type, :organization => @organization)
    end
    specify "should have the org embedded in the permission" do
      @magic_perm.organization.should_not be_nil
    end
  end

  context "all_tag tests" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
      @role = Role.find_or_create_by_name(:name => 'another_Role')
    end

    describe "Creating a permission with all_types" do
      before(:each) do
        @perm = Permission.new(:name=>"aname", :resource_type =>ResourceType.find_or_create_by_name(:all))
        @perm.role = @role
      end

      specify "shouldn't be allowed without all_tags '" do
        @perm.all_verbs = true
        @perm.all_types?.should be_true
        @perm.save.should be_false
      end

      specify "shouldn't be allowed without all_verbs '" do
        @perm.all_tags = true
        @perm.all_types?.should be_true
        @perm.save.should be_false
      end

      specify "should be allowed with all_verbs and all_tags" do
        @perm.all_verbs = true
        @perm.all_tags = true
        @perm.save.should be_true
      end

    end
  end

  context "cleanup" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_organization_1', :label=> 'test_organization_1')
    end

    describe "after organization deletion" do
      before do
        @organization2 = Organization.create!(:name=>'test_organization_2', :label=> 'test_organization_2')
        Permission.create!(:name => 'test1001', :role => @some_role, :tag_values=> [@organization.id, @organization2.id],
                                         :resource_type=> ResourceType.find_or_create_by_name('organizations'), :organization => @organization)
      end

      specify "should result in removal of organization-specific tags" do
        Organization.any_instance.stub(:being_deleted?).and_return(true)
        @organization2.destroy
        Permission.find_by_name('test1001').tag_values.should == [@organization.id]
      end
    end

    describe "after environment deletion" do
      before do
        disable_env_orchestration
        @environment = KTEnvironment.create!(
            {:name=>"test1000", :label=> "test100", :organization => @organization, :prior => @organization.library})
        @environment2 = KTEnvironment.create!(
            {:name=>"test1001", :label=> "test101", :organization => @organization, :prior => @organization.library})

        p = Permission.new(:name => 'test1001', :role => @some_role, :tag_values=> [@environment.id, @environment2.id],
           :resource_type=> ResourceType.find_or_create_by_name('environments'), :organization => @organization)
        p.save!
      end

      specify "should result in removal of environment-specific tags" do
        @environment.destroy
        Permission.find_by_name('test1001').tag_values.should == [@environment2.id]
      end
    end

    describe "after provider deletion" do
      before do
        @provider = Provider.create!({:name => 'test1000', :repository_url => 'https://something.net',
          :provider_type => Provider::CUSTOM, :organization => @organization})
        @provider2 = Provider.create!({:name => 'test1001', :repository_url => 'https://something2.net',
                                      :provider_type => Provider::CUSTOM, :organization => @organization})
        Permission.create!(:name => 'test1001', :role => @some_role, :tag_values=> [@provider.id, @provider2.id],
                                   :resource_type=> ResourceType.find_or_create_by_name('providers'), :organization => @organization)
      end

      specify "should result in removal of provider-specific tags" do
        @provider.destroy
        Permission.find_by_name('test1001').tag_values.should == [@provider2.id]
      end
    end

    describe "after system group deletion" do
      before do
        disable_consumer_group_orchestration

        @group = SystemGroup.create!(:name=>"TestSystemGroup", :organization=>@organization)
        @group2 = SystemGroup.create!(:name=>"TestSystemGroup2", :organization=>@organization)
        Permission.create!(:name => 'test1001', :role => @some_role, :tag_values=> [@group.id, @group2.id],
                           :resource_type=> ResourceType.find_or_create_by_name('system_groups'), :organization => @organization)
      end

      it "should result in removal of system-group-specific tags", :katello => true do #TODO headpin
        @group.destroy
        Permission.find_by_name('test1001').tag_values.should == [@group2.id]
      end
    end
  end
end
