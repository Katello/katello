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
  before(:all) do
    @some_role = Role.create!(:name => 'some_role')
    @repo_admin = Role.create!(:name => 'repo_admin')
    @super_admin = Role.create!(:name => 'super_admin', :superadmin => true)

    user_admin = User.create!(
      :username => 'admin',
      :password => "password",
      :roles => [ @some_role ])
    user_bob = User.create!(
      :username => 'bob',
      :password => "password",
      :roles => [ @repo_admin ])

    @some_role.allow [:create], :organization
    @some_role.allow [:new], :organization
    @some_role.allow [:test], :test1
    @some_role.allow [:test], :test2
    @some_role.allow [:test], :test3
    @repo_admin.allow :create_repo, :repogroup, :repogroup_internal
    @repo_admin.allow :delete_repo, :repo, [:repogroup_internal, :repo_rhel6]
  end

  it "should list tags properly" do
    ResourceType.all.collect{|t| t.name}.sort.should ==  ["organization", "test1", "test2", "test3", "repo", "repogroup"].sort
  end

  it "should list verbs properly" do
    Verb.verbs_for("repogroup").collect{|t| t.verb}.sort.should ==  ["create_repo"]
  end

  context "super_admin" do
    it { @super_admin.allowed_to?('create', 'organization').should be_true }
    it { @super_admin.allowed_to?('anything', 'anything').should be_true }
    it { @super_admin.allowed_to?('anything', 'anything', 'anything').should be_true }
  end

  context "some_role" do
    it { @some_role.allowed_to?('create', 'organization').should be_true }
    it { @some_role.allowed_to?('new', 'organization').should be_true }
    it { @some_role.allowed_to?('destroy', 'organization').should be_false }
    it { @some_role.allowed_to?('create', 'xxx').should be_false }
  end

  context "repo_admin" do
    it { @repo_admin.allowed_to?('create', 'organization').should be_false }
    it { @repo_admin.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_true }
    it { @repo_admin.allowed_to?("create_repo", "repogroup", 'repogroup_external').should be_false }
    it { @repo_admin.allowed_to?("create_repo", "repo-bad").should be_false }
    it { @repo_admin.allowed_to?("delete_repo", "repo", [:repogroup_internal, :repo_rhel6]).should be_true }
    it { @repo_admin.allowed_to?("delete_repo", "repo", [:repogroup_internal]).should be_true }
    it { @repo_admin.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_true }
    it { @repo_admin.allowed_to?("delete_repo", "repo", [:repogroup_internal]).should be_true }
    it {
      @repo_admin.disallow("create_repo", "repogroup", :repogroup_internal)
      @repo_admin.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_false
    }
  end

end
