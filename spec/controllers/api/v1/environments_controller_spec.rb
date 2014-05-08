#
# Copyright 2014 Red Hat, Inc.
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
describe Api::V1::EnvironmentsController do
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  before(:each) do
    @org                      = Organization.new(:label => "1")
    @environment              = LifecycleEnvironment.new
    @environment.organization = @org
    @controller.stubs(:get_organization).returns(@org)

    @request.env["HTTP_ACCEPT"] = "application/json"
    setup_controller_defaults_api
  end

  let(:user_with_read_permissions) do
    user_with_permissions { |u| u.can(Organization::READ_PERM_VERBS, :organizations, nil, @ogranization) }
  end
  let(:user_without_read_permissions) do
    user_without_permissions
  end
  let(:user_with_manage_permissions) do
    user_with_permissions { |u| u.can([:update, :create], :organizations, nil, @ogranization) }
  end
  let(:user_without_manage_permissions) do
    # todo - it's sufficient to have only one permission?
    # user_with_permissions { |u| u.can([:update], :organizations, nil, @ogranization) }
    user_without_permissions
  end
  let(:user_with_register_systems_permission) do
    user_with_permissions { |u| u.can([:register_system], :organizations, nil, @ogranization) }
  end
  let(:user_without_register_systems_permission) do
    user_without_permissions
  end

  describe "create an environment" do
    before(:each) do
      LifecycleEnvironment.expects(:new).once.returns(@environment)
      @environment.expects(:valid?).returns(true)
      @org.expects(:save!).once
    end

    it 'should call katello create environment api' do
      post 'create', :organization_id => "1", :environment => { :name => "production", :description => "a" }
    end
  end

  describe "bad create request" do
    let(:req) do
      bad_req = { :organization_id => 1,
                  :environment     =>
                      { :bad_foo     => "mwahahaha",
                        :name        => "production",
                        :description => "This is the key string" }
      }.with_indifferent_access
      post :create, bad_req
    end
    it_should_behave_like "bad request"
  end

  describe "search a list of environments" do
    let(:action) { :index }
    let(:req) { get 'index', { :organization_id => "1", :name => "foo" } }

    it 'should call katello environment find api' do
      LifecycleEnvironment.expects(:where).once.returns([@environment])
      req
    end

    context 'from katello cli' do
      before do
        request.stubs(:user_agent).returns('katello-cli')
      end

      it 'should return empty set when not found by name' do
        LifecycleEnvironment.stubs(:where => [])
        LifecycleEnvironment.expects(:where).once
        req
      end
    end

    context 'from subscription-manager' do
      before do
        request.stubs(:user_agent).returns(nil)
      end

      it ' should try again with label when not found by name' do
        LifecycleEnvironment.expects(:where).with do |search_query|
          search_query['name'] == 'foo'
        end.once.returns([])
        LifecycleEnvironment.expects(:where).with do |search_query|
          search_query['label'] == 'foo'
        end.once
        req
      end
    end

  end

  describe "show a environment" do

    before(:each) do
      LifecycleEnvironment.stubs(:find => @environment)
    end

    let(:action) { :show }
    let(:req) { get 'show', :id => 1, :organization_id => "1" }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it 'should call LifecycleEnvironment.first' do
      LifecycleEnvironment.expects(:find).once().returns(@environment)
      req
    end
  end

  describe "delete a environment" do
    before (:each) do
      LifecycleEnvironment.expects(:find).once().returns(@environment)
    end

    let(:action) { :destroy }
    let(:req) { delete 'destroy', :id => 1, :organization_id => "1" }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it 'should call katello environment find api' do
      @environment.expects(:destroy).once
      req
    end
  end

  describe "bad update request" do
    let(:req) do
      bad_req = { :organization_id => 1,
                  :id              => 1000,
                  :environment     =>
                      { :bad_foo     => "mwahahaha",
                        :name        => "production",
                        :description => "This is the key string" }
      }.with_indifferent_access
      put :update, bad_req
    end

    it_should_behave_like "bad request"
  end

  describe "update an environment" do

    before(:each) do
      LifecycleEnvironment.stubs(:find => @environment)
    end

    let(:action) { :update }
    let(:req) { put 'update', :id => 'to_update', :organization_id => "1", :environment => { "name" => @environment.name } }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it 'should call KPEnvironment update_attributes' do
      LifecycleEnvironment.expects(:find).once().returns(@environment)
      @environment.expects(:update_attributes!).once.returns(@environment)
      req
    end
  end

  describe "list available releases" do
    before(:each) do
      LifecycleEnvironment.stubs(:find => @environment)
    end

    let(:action) { :releases }
    let(:req) { get :releases, :id => "123" }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should show releases that are available in given environment" do
      @environment.expects(:available_releases).returns(["6.1", "6.2", "6Server"])
      req
      JSON.parse(response.body).must_equal( { "releases" => ["6.1", "6.2", "6Server"] })
    end
  end

end
end