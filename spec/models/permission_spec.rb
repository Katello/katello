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
  before(:all) do
    @some_role = Role.find_or_create_by_name(:name => 'some_role')
    @repo_admin = Role.find_or_create_by_name(:name => 'repo_admin')
    @super_admin = Role.find_or_create_by_name(:name => 'super_admin')

    @magic_perm = Permission.create!(:role => @super_admin, 
                                :resource_type=> nil, :organization => nil)



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


    @some_role.allow [:create], :organization
    @some_role.allow [:new], :organization
    @some_role.allow [:test], :test1
    @some_role.allow [:test], :test2
    @some_role.allow [:test], :test3
    ResourceType::TYPES[:repogroup] = {:model => OpenStruct.new(:list_verbs => {"create_repo" => "Description"})}
    @repo_admin.allow :create_repo, :repogroup, :repogroup_internal
    @repo_admin.allow :delete_repo, :repo, [:repogroup_internal, :repo_rhel6]
  end

  it "should list tags properly" do
    ResourceType.all.collect{|t| t.name}.sort.should ==  ["organization", "test1", "test2", "test3", "repo", "repogroup"].sort
  end

  it "should list verbs properly" do
    Verb.verbs_for("repogroup").keys.should ==  ["create_repo"]
  end

  context "super_admin" do
    it { @god.allowed_to?('create', 'organization').should be_true }
    it { @god.allowed_to?('anything', 'anything').should be_true }
    it { @god.allowed_to?('anything', 'anything', 'anything').should be_true }
  end

  context "some_role" do
    it { @admin.allowed_to?('create', 'organization').should be_true }
    it { @admin.allowed_to?('new', 'organization').should be_true }
    it { @admin.allowed_to?('destroy', 'organization').should be_false }
    it { @admin.allowed_to?('create', 'xxx').should be_false }
  end

  context "repo_admin" do
    it { @user_bob.allowed_to?('create', 'organization').should be_false }
    it { @user_bob.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_true }
    it { @user_bob.allowed_to?("create_repo", "repogroup", 'repogroup_external').should be_false }
    it { @user_bob.allowed_to?("create_repo", "repo-bad").should be_false }
    it { @user_bob.allowed_to?("delete_repo", "repo", [:repogroup_internal, :repo_rhel6]).should be_true }
    it { @user_bob.allowed_to?("delete_repo", "repo", [:repogroup_internal]).should be_true }
    it { @user_bob.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_true }
    it { @user_bob.allowed_to?("delete_repo", "repo", [:repogroup_internal]).should be_true }
    it {
      @repo_admin.disallow("create_repo", "repogroup", :repogroup_internal)
      @user_bob.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_false
    }
  end

  context "global org tests" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
    end
    describe "allow all resources  globally" do
      before do
         @magic_perm = Permission.create!(:role => @some_role,
                                     :resource_type=> nil, :organization => nil)
      end
      specify {Permission.last.all_types.should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, @organization).should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, nil).should be_true}
    end

    describe "allow all verbs" do
      before do
        @tag_name = "magic_tag"
        @tag = Tag.find_or_create_by_name(@tag_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:role => @some_role, :all_verbs => true, :tags =>[@tag],
                                      :resource_type=> @res_type)
      end
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, "").should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, "", @organization).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name, @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "Foo", :magic_tag).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "Foo", :magic_tag, @organization).should be_false}
    end

    describe "allow all tags" do
      before do
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:role => @some_role, :verbs => [@verb],
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
        @magic_perm = Permission.create!(:role => @some_role, :verbs => [@verb],
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
        @magic_perm = Permission.create!(:role => @some_role, :verbs => [@verb],
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
    end
    describe "allow all resources orgwise" do
      before do
         @magic_perm = Permission.create!(:role => @some_role,
                                     :resource_type=> nil, :organization => @organization)
      end
      specify {Permission.last.all_types.should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, @organization).should be_true}
      specify { @admin.allowed_to?(:foo_verb, :bar_resource_type, nil, nil).should be_false}
    end

    describe "allow all verbs" do
      before do
        @tag_name = "magic_tag"
        @tag = Tag.find_or_create_by_name(@tag_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:role => @some_role, :all_verbs => true,:tags => [@tag],
                                      :resource_type=> @res_type, :organization => @organization)
      end
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, "").should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, "", @organization).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name, @tag_name, @organization).should be_true}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "Foo", :magic_tag).should be_false}
      specify {@admin.allowed_to?("do_magic_verb", @res_type_name + "Foo", :magic_tag, @organization).should be_false}
    end

    describe "allow all tags" do
      before do
        @verb_name = "magic_verb"
        @verb = Verb.find_or_create_by_verb(@verb_name)
        @res_type_name = "TestResourceType"
        @res_type = ResourceType.find_or_create_by_name(@res_type_name)
        @magic_perm = Permission.create!(:role => @some_role, :verbs => [@verb],
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

  end


  context "org_id_create" do
    before do
      disable_org_orchestration
      @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
      @res_type_name = "TestResourceType"
      @res_type = ResourceType.find_or_create_by_name(@res_type_name)
      @magic_perm = Permission.create!(:role => @some_role, :all_verbs => true,
                                   :resource_type=> @res_type, :organization => @organization)
    end
    specify "should have the org embedded in the permission" do
      @magic_perm.organization.should_not be_nil
    end
  end

end
