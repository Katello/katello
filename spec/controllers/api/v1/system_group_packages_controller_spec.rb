
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

require 'spec_helper.rb'
include OrchestrationHelper

describe Api::V1::SystemGroupPackagesController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods

  let(:user_with_update_permissions) { user_with_permissions { |u| u.can(:update_systems, :system_groups, @group.id, @organization) } }
  let(:user_without_update_permissions) { user_without_permissions }

  let(:package_groups) { %w[@Editors FTP Server] }
  let(:packages) { %w[zsh bash] }

  before(:each) do
    login_user(:mock => false)
    set_default_locale
    new_test_org

    disable_consumer_group_orchestration
    @group = SystemGroup.create!(:name=>"test_group", :organization=>@organization, :max_systems => 5)
    SystemGroup.stub!(:find).and_return(@group)
  end

  describe "install package" do
    before do
      @group.stub(:install_packages).and_return(TaskStatus.new())
    end

    let(:action) { :create }
    let(:req) { post :create, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }

    it_should_behave_like "protected action"

    it { should be_successful }

    it "should call model to install packages" do
      @group.should_receive(:install_packages)
      subject
    end

  end

  describe "install package group" do
    before do
      @group.stub(:install_package_groups).and_return(TaskStatus.new())
    end

    subject { post :create, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups }

    it { should be_successful }

    it "should call model to install package groups" do
      @group.should_receive(:install_package_groups)
      subject
    end
  end

  describe "remove package" do
    before do
      @group.stub(:uninstall_packages).and_return(TaskStatus.new())
    end

    let(:action) { :destroy }
    let(:req) { delete :destroy, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it { should be_successful }

    it "should call model to remove packages" do
      @group.should_receive(:uninstall_packages)
      subject
    end
  end

  describe "remove package group" do
    before do
      @group.stub(:uninstall_package_groups).and_return(TaskStatus.new())
    end

    subject { delete :destroy, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups }

    it { should be_successful }

    it "should call model to remove package groups" do
      @group.should_receive(:uninstall_package_groups)
      subject
    end
  end

  describe "update package" do
    before do
      @group.stub(:update_packages).and_return(TaskStatus.new())
    end

    let(:action) { :create }
    let(:req) { put :update, :organization_id => @organization.name, :system_group_id => @group.id, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it { should be_successful }

    it "should call model to update packages" do
      @group.should_receive(:update_packages)
      subject
    end
  end

  describe "update package groups" do
    before do
      @group.stub(:install_package_groups).and_return(TaskStatus.new())
    end

    subject { put :update, :organization_id => @organization.name, :system_group_id => @group.id, :groups => package_groups }

    it { should be_successful }

    it "should call model to update package groups" do
      @group.should_receive(:install_package_groups)
      subject
    end
  end
end
