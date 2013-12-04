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

require 'katello_test_helper'

module Katello
describe Api::V1::SystemGroupPackagesController do
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods

  let(:user_with_update_permissions) { user_with_permissions { |u| u.can(:update_systems, :system_groups, @group.id, @organization) } }
  let(:user_without_update_permissions) { user_without_permissions }

  let(:package_groups) { %w[@Editors FTP Server] }
  let(:packages) { %w[zsh bash] }

  describe "(katello)" do

  before(:each) do
    setup_controller_defaults_api

    new_test_org
    System.any_instance.stub(:update_system_groups)

    disable_consumer_group_orchestration
    @group = SystemGroup.create!(:name => "test_group", :organization => @organization, :max_systems => 5)
    SystemGroup.stubs(:find).returns(@group)
  end

  describe "install package" do
    before do
      @group.stubs(:install_packages).returns(TaskStatus.new())
    end

    let(:action) { :create }
    let(:req) { post :create, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }

    it_should_behave_like "protected action"

    it "should call model to install packages" do
      @group.expects(:install_packages)
      subject
    end

    it "should be successful" do
      post :create, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages
      must_respond_with(:success)
    end
  end

  describe "install package group" do
    before do
      @group.stubs(:install_package_groups).returns(TaskStatus.new())
    end

    subject { post :create, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups }

    it "should call model to install package groups" do
      @group.expects(:install_package_groups)
      subject
    end

    it "should be successful" do
      post :create, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups
      must_respond_with(:success)
    end
  end

  describe "remove package" do
    before do
      @group.stubs(:uninstall_packages).returns(TaskStatus.new())
    end

    let(:action) { :destroy }
    let(:req) { delete :destroy, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it "should call model to remove packages" do
      @group.expects(:uninstall_packages)
      subject
    end

    it "should be successful" do
      delete :destroy, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages
      must_respond_with(:success)
    end
  end

  describe "remove package group" do
    before do
      @group.stubs(:uninstall_package_groups).returns(TaskStatus.new())
    end

    subject { delete :destroy, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups }

    it "should call model to remove package groups" do
      @group.expects(:uninstall_package_groups)
      subject
    end

    it "should be successful" do
      delete :destroy, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups
      must_respond_with(:success)
    end
  end

  describe "update package" do
    before do
      @group.stubs(:update_packages).returns(TaskStatus.new())
    end

    let(:action) { :create }
    let(:req) { put :update, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it "should call model to update packages" do
      @group.expects(:update_packages)
      subject
    end

    it "should be successful" do
      put :update, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages
      must_respond_with(:success)
    end
  end

  describe "update package groups" do
    before do
      @group.stubs(:install_package_groups).returns(TaskStatus.new())
    end

    subject { put :update, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups }

    it "should call model to update package groups" do
      @group.expects(:install_package_groups)
      subject
    end

    it "should be successful" do
      put :update, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups
      must_respond_with(:success)
    end
  end
  end
end
end
