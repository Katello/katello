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

describe Api::V1::SystemPackagesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods

  let(:uuid) { '1234' }

  let(:user_with_update_permissions) { user_with_permissions { |u| u.can(:update_systems, :organizations, nil, @organization) } }
  let(:user_without_update_permissions) { user_without_permissions }

  let(:package_groups) { %w[@Editors FTP Server] }
  let(:packages) { %w[zsh bash] }

  before(:each) do
    login_user(:mock => false)
    set_default_locale
    disable_org_orchestration
    User.current = @user
    Resources::Candlepin::Consumer.stub!(:create).and_return({ :uuid => uuid, :owner => { :key => uuid } })
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)

    if Katello.config.katello?
      Runcible::Extensions::Consumer.stub!(:create).and_return({ :id => uuid })
      Runcible::Extensions::Consumer.stub!(:update).and_return(true)
    end

    @organization  = Organization.create!(:name => 'test_org', :label => 'test_org')
    @environment_1 = KTEnvironment.create!(:name => 'test_1', :label => 'test_1', :prior => @organization.library.id, :organization => @organization)
    @system        = System.create!(:environment => @environment_1, :uuid => "1234", :name => "system.example.com", :cp_type => 'system', :facts => { :foo => :bar })
    System.stub(:first => @system)
  end

  describe "install package" do

    before do
      @task_status = stub_task_status(:package_install, :packages => packages)
      @system.stub(:install_packages).and_return(@task_status)
    end

    let(:action) { :create }
    let(:req) { post :create, :organization_id => @organization.name, :system_id => @system.uuid, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it { should be_successful }

    it "should call model to install packages" do
      @system.should_receive(:install_packages)
      subject
    end

  end

  describe "install package group" do

    before do
      @task_status = stub_task_status(:package_group_install, :groups => package_groups)
      @system.stub(:install_package_groups).and_return(@task_status)
    end

    subject { post :create, :organization_id => @organization.name, :system_id => @system.uuid, :groups => package_groups }

    it { should be_successful }

    it "should call model to install packages" do
      @system.should_receive(:install_package_groups)
      subject
    end

  end

  describe "remove package" do

    before do
      @task_status = stub_task_status(:package_remove, :packages => packages)
      @system.stub(:uninstall_packages).and_return(@task_status)
    end

    let(:action) { :destroy }
    let(:req) { delete :destroy, :organization_id => @organization.name, :system_id => @system.uuid, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it { should be_successful }

    it "should call model to remove packages" do
      @system.should_receive(:uninstall_packages)
      subject
    end

  end

  describe "remove package group" do

    before do
      @task_status = stub_task_status(:package_group_remove, :groups => package_groups)
      @system.stub(:uninstall_package_groups).and_return(@task_status)
    end

    subject { delete :destroy, :organization_id => @organization.name, :system_id => @system.uuid, :groups => package_groups }

    it { should be_successful }

    it "should call model to remove package groups" do
      @system.should_receive(:uninstall_package_groups)
      subject
    end

  end

  describe "update package" do

    before do
      @task_status = stub_task_status(:package_update, :packages => packages)
      @system.stub(:update_packages).and_return(@task_status)
    end

    let(:action) { :create }
    let(:req) { put :update, :organization_id => @organization.name, :system_id => @system.uuid, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it { should be_successful }

    it "should call model to update packages" do
      @system.should_receive(:update_packages)
      subject
    end

  end


  def stub_task_status(task_type, parameters, status = "running", result = { :errors => [] })
    return TaskStatus.create(:organization_id => @organization.id,
                             :task_type       => task_type,
                             :parameters      => parameters,
                             :result          => result,
                             :state           => status,
                             :uuid            => "1234")
  end

end
