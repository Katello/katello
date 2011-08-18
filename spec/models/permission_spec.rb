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
describe Permission do
  include OrchestrationHelper
  include AuthorizationHelperMethods
  def add_test_type type, verbs
    verb_hash = {}
    verbs.each{|v|
      verb_hash[v.to_s] = "description"

    }

    ResourceType::TYPES[type] = {:model => OpenStruct.new(:no_tag_verbs => [],
      :list_verbs => verb_hash)}
    
  end


  before(:all) do
    @some_role = Role.find_or_create_by_name(:name => 'some_role')
    @repo_admin = Role.find_or_create_by_name(:name => 'repo_admin')
    @super_admin = Role.find_or_create_by_name(:name => 'super_admin')

    @magic_perm = Permission.create!(:role => @super_admin, :name => :test1000,
                                :resource_type=> ResourceType.find_or_create_by_name(:all),
                                :all_tags => true, :all_verbs => true, :organization => nil)


    @god = User.find_or_create_by_username(
      :username => 'god',
      :password => "password",
      :roles => [ @super_admin ])

    @admin = User.find_or_create_by_username(
      :username => 'admin',
      :password => "password",
      :roles => [ @some_role ])
    @user_bob = User.find_or_create_by_username(
      :username => 'bob',
      :password => "password",
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

    allow @repo_admin, :create_repo, :repogroup, :repogroup_internal
    allow @repo_admin, :delete_repo, :repo, [:repogroup_internal, :repo_rhel6]
  end

  it "should list tags properly" do
    ResourceType.all.collect{|t| t.name}.sort.should_not == nil
  end

  it "should list verbs properly" do
    Verb.verbs_for("repogroup").keys.should include  "create_repo"
  end

  context "super_admin" do
    it { @god.allowed_to?('create', 'organizations').should be_true }
    it { @god.allowed_to?('create', 'providers').should be_true }
  end

  context "some_role" do
    it { @admin.allowed_to?('create', 'organizations').should be_true }
    it { @admin.allowed_to?('delete', 'organizations').should be_false }
    it { @admin.allowed_to?('create', 'xxx').should be_false }
  end

  context "repo_admin" do
    it { @user_bob.allowed_to?('create', 'organizations').should be_false }
    it { @user_bob.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_true }
    it { @user_bob.allowed_to?("create_repo", "repogroup", 'repogroup_external').should be_false }
    it { @user_bob.allowed_to?("create_repo", "repo-bad").should be_false }
    it { @user_bob.allowed_to?("delete_repo", "repo", [:repogroup_internal, :repo_rhel6]).should be_true }
    it { @user_bob.allowed_to?("delete_repo", "repo", [:repogroup_internal]).should be_true }
    it { @user_bob.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_true }
    it { @user_bob.allowed_to?("delete_repo", "repo", [:repogroup_internal]).should be_true }
  end

  context "global org tests" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
      add_test_type(:bar_resource_type, [:foo_verb])
    end
    describe "allow all resources  globally" do
      before do
         @magic_perm = Permission.create!(:role => @some_role, :all_verbs=> true, :name => :test1000, :all_tags=> true,
                           :resource_type=> ResourceType.find_or_create_by_name(:all), :organization => nil)
      end
      specify {Permission.last.all_types?.should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, @organization).should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, nil).should be_true}
    end

    describe "allow all verbs" do
      before do
        @tag_name = "magic_tag"
        @tag = Tag.find_or_create_by_name(@tag_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :all_verbs => true, :tags =>[@tag],
                                      :resource_type=> @res_type)
      end
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, "").should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, "", @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name, @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "foo", :magic_tag).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "foo", :magic_tag, @organization).should be_false}
    end

    describe "allow all tags" do
      before do
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :verbs => [@verb],
                                         :all_tags=> true,
                                      :resource_type=> @res_type)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,:foo_tag).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,:foo_tag, @organization).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",:foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",:foo_tag, @organization).should be_false}
      specify{@admin.allowed_to?(@verb_name + "_foo", @res_type_name,:foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name + "_foo", @res_type_name,:foo_tag, @organization).should be_false}
    end


    describe "regular perms" do
      before do
        @tag_name = "magic_tag"
        @tag = Tag.find_or_create_by_name(@tag_name)
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :verbs => [@verb],
                                         :tags=> [@tag],
                                      :resource_type=> @res_type)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,[@tag_name]).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,[@tag_name], @organization).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,[@tag_name + "foo"]).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",[:foo_tag], @organization).should be_false}
    end

    describe "regular perms no tags" do
      before do
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :verbs => [@verb],
                                      :resource_type=> @res_type)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,nil).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,nil, @organization).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,["foo"]).should be_false}
    end


  end

  context "non global org tests" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
      add_test_type :bar_resource_type, ["foo_verb"]
    end
    describe "allow all resources orgwise" do
      before do
         @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :all_tags=> true, :all_verbs=>true,
                         :resource_type=> ResourceType.find_or_create_by_name(:all), :organization => @organization)
      end
      specify {Permission.last.all_types?.should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, @organization).should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, nil).should be_false}
    end

    describe "allow all verbs" do
      before do
        @tag_name = "magic_tag"
        @tag = Tag.find_or_create_by_name(@tag_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :all_verbs => true,:tags => [@tag],
                                      :resource_type=> @res_type, :organization => @organization)
      end
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, "").should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, "", @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name, @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "foo", :magic_tag).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "foo", :magic_tag, @organization).should be_false}
    end

    describe "allow all tags" do
      before do
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :verbs => [@verb],
                                         :all_tags=> true,
                                      :resource_type=> @res_type, :organization => @organization)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,:foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,:foo_tag, @organization).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",:foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name + "foo",:foo_tag, @organization).should be_false}
      specify{@admin.allowed_to?(@verb_name + "_foo", @res_type_name,:foo_tag).should be_false}
      specify{@admin.allowed_to?(@verb_name + "_foo", @res_type_name,:foo_tag, @organization).should be_false}
    end


    describe "no_tag_verbs" do
      before do
        @res_type_name = :providers
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @no_tag_verbs = Provider.no_tag_verbs
        @verb_name = @no_tag_verbs.first
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :verbs => [@verb],
                                      :resource_type=> @res_type, :organization => @organization)
      end
      specify{@admin.allowed_to?(@verb_name, @res_type_name,nil, @organization).should be_true}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,:foo_tag, @organization).should be_true}

      specify{@admin.allowed_to?(@verb_name, @res_type_name,nil,nil).should be_false}
      specify{@admin.allowed_to?(@verb_name, @res_type_name,:foo_tag, nil).should be_false}
    end

  end


  context "org_id_create" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
      @res_type_name = "TestResourceType"
      @res_type = ResourceType.find_or_create_by_name(@res_type_name)
      @magic_perm = Permission.create!(:name => :test1000, :role => @some_role, :all_verbs => true,
                                   :resource_type=> @res_type, :organization => @organization)
    end
    specify "should have the org embedded in the permission" do
      @magic_perm.organization.should_not be_nil
    end
  end

  context "all_tag tests" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
      @role = Role.find_or_create_by_name(:name => 'another_Role')
    end

    describe "Creating a permission with all_types" do
      before(:each) do
        @perm = Permission.new(:name=>"aname", :resource_type =>ResourceType.find_or_create_by_name(:all))
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


end
