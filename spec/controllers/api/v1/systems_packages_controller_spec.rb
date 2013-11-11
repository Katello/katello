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
    Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid, :owner => { :key => uuid } })
    Resources::Candlepin::Consumer.stubs(:update).returns(true)

    if Katello.config.katello?
      Katello.pulp_server.extensions.consumer.stubs(:create).returns({ :id => uuid })
      Katello.pulp_server.extensions.consumer.stubs(:update).returns(true)
    end

    @organization  = Organization.create!(:name => 'test_org', :label => 'test_org')
    @environment_1 = create_environment(:name => 'test_1', :label => 'test_1', :prior => @organization.library.id, :organization => @organization)
    @system        = create_system(:environment => @environment_1, :uuid => "1234", :name => "system.example.com", :cp_type => 'system', :facts => { :foo => :bar })
    System.stubs(:first => @system)
  end

  describe "install package" do

    before do
      @task_status = stub_task_status(:package_install, :packages => packages)
      @system.stubs(:install_packages).returns(@task_status)
    end

    let(:action) { :create }
    let(:req) { post :create, :organization_id => @organization.name, :system_id => @system.uuid, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it { must_be_successful }

    it "should call model to install packages" do
      @system.expects(:install_packages)
      subject
    end

  end

  describe "install package group" do

    before do
      @task_status = stub_task_status(:package_group_install, :groups => package_groups)
      @system.stubs(:install_package_groups).returns(@task_status)
    end

    subject { post :create, :organization_id => @organization.name, :system_id => @system.uuid, :groups => package_groups }

    it { must_be_successful }

    it "should call model to install packages" do
      @system.expects(:install_package_groups)
      subject
    end

  end

  describe "remove package" do

    before do
      @task_status = stub_task_status(:package_remove, :packages => packages)
      @system.stubs(:uninstall_packages).returns(@task_status)
    end

    let(:action) { :destroy }
    let(:req) { delete :destroy, :organization_id => @organization.name, :system_id => @system.uuid, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it { must_be_successful }

    it "should call model to remove packages" do
      @system.expects(:uninstall_packages)
      subject
    end

  end

  describe "remove package group" do

    before do
      @task_status = stub_task_status(:package_group_remove, :groups => package_groups)
      @system.stubs(:uninstall_package_groups).returns(@task_status)
    end

    subject { delete :destroy, :organization_id => @organization.name, :system_id => @system.uuid, :groups => package_groups }

    it { must_be_successful }

    it "should call model to remove package groups" do
      @system.expects(:uninstall_package_groups)
      subject
    end

  end

  describe "update package" do

    before do
      @task_status = stub_task_status(:package_update, :packages => packages)
      @system.stubs(:update_packages).returns(@task_status)
    end

    let(:action) { :create }
    let(:req) { put :update, :organization_id => @organization.name, :system_id => @system.uuid, :packages => packages }
    subject { req }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it { must_be_successful }

    it "should call model to update packages" do
      @system.expects(:update_packages)
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
