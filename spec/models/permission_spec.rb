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
  before(:each) do
    user_admin = User.create!(:username => 'admin', :password=>"password")
    user_bob = User.create!(:username => 'bob', :password=>"password")

    role_superadmin = Role.create!(:name => 'super_admin')
    role_repoadmin = Role.create!(:name => 'repo_admin')

    user_admin.roles << role_superadmin
    user_admin.save
    user_bob.roles << role_repoadmin
    user_bob.save

    Role.allow 'super_admin', [:create], :organization
    Role.allow 'super_admin', [:new], :organization
    Role.allow 'super_admin', [:test], :test1
    Role.allow 'super_admin', [:test], :test2
    Role.allow 'super_admin', [:test], :test3
    Role.allow 'repo_admin', :create_repo, :repogroup, :repogroup_internal
    Role.allow 'repo_admin', :delete_repo, :repo, [:repogroup_internal, :repo_rhel6]
  end

  it "should list tags properly" do
    ResourceType.all.collect{|t| t.name}.sort.should ==  ["organization", "test1", "test2", "test3", "repo", "repogroup"].sort
  end

  it "should list verbs properly" do
    Verb.verbs_for("repogroup").collect{|t| t.verb}.sort.should ==  ["create_repo"]
  end

  it "should allow superadmin to organization/create in rails" do
    r = Role.find_by_name('super_admin')
    r.allowed_to?('create', 'organization').should be_true
  end

  it "should allow superadmin to organization/new in rails" do
    r = Role.find_by_name('super_admin')
    r.allowed_to?('new', 'organization').should be_true
  end

  it "should deny repoadmin to organization/create in rails" do
    r = Role.find_by_name('repo_admin')
    r.allowed_to?('create', 'organization').should be_false
  end

  it "should deny superadmin to xxx/create in rails" do
    r = Role.find_by_name('super_admin')
    r.allowed_to?('create', 'xxx').should be_false
  end

  it "allow repoadmin to create_repo in repogroup with tags repogroup:internal" do
    r = Role.find_by_name('repo_admin')
    r.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_true
  end

  it "deny repoadmin to create_repo in repogroup" do
    r = Role.find_by_name('repo_admin')
    r.allowed_to?("create_repo", "repogroup", 'repogroup_external').should be_false
  end

  it "deny repoadmin to create_repo" do
    r = Role.find_by_name('repo_admin')
    r.allowed_to?("create_repo", "repo-bad").should be_false
  end

  it "allow repoadmin to delete_repo in repo with tags repogroup:internal repo:rhel6" do
    r = Role.find_by_name('repo_admin')
    r.allowed_to?("delete_repo", "repo", [:repogroup_internal, :repo_rhel6]).should be_true
  end

  it "deny repoadmin to delete_repo in repo with tags repogroup:internal" do
    r = Role.find_by_name('repo_admin')
    r.allowed_to?("delete_repo", "repo", [:repogroup_internal]).should be_true
  end

  it "disallow create_repo to repo_admin" do
    r = Role.find_by_name('repo_admin')
    r.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_true
    r.disallow("create_repo", "repogroup", :repogroup_internal)
    r.allowed_to?("create_repo", "repogroup", :repogroup_internal).should be_false
  end

end
