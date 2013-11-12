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
describe ChangesetsController do

  describe "(katello)" do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  module CSControllerTest

    ENV_NAME = "environment_name"
    ENVIRONMENT = {:name => ENV_NAME, :label=>"env_label", :description => nil}
    NEXT_ENVIRONMENT = {:name => "next_env_name", :label => "next_env_name", :description => nil}
    CHANGESET = {:id=>1, :promotion_date=>Time.now, :name=>"oldname"}

  end

  before(:each) do
    setup_controller_defaults

    @org = new_test_org

    CSControllerTest::ENVIRONMENT["organization"] = @org
    CSControllerTest::ENVIRONMENT["prior"] = @org.library.id
    @env = create_environment(CSControllerTest::ENVIRONMENT)
    CSControllerTest::NEXT_ENVIRONMENT["organization"] = @org
    @next_env = KTEnvironment.new(CSControllerTest::NEXT_ENVIRONMENT)
    @next_env.prior = @env
    @next_env.save!

    CSControllerTest::CHANGESET["environment_id"] = @env.id
  end

  describe "viewing changesets" do
    before (:each) do
      @changeset = PromotionChangeset.create(CSControllerTest::CHANGESET)
    end

    it "should show the changeset 2 pane list" do
      get :index
      must_respond_with(:success)
    end

    it "changesetuser should be empty" do
      get :index
      @changeset.users.must_be_empty
    end

    it "should return a portion of changesets for an environment" do
      @controller.expects(:render_panel_direct)
      @controller.stubs(:render).returns('')

      get :items, :env_id=>@env.id
      must_respond_with(:success)
    end

    it "should be able to show the edit partial" do
      get :edit, :id=>@changeset.id
      must_respond_with(:success)
    end

    it "should be able to update the name of a changeset" do
      post :update, :id=>@changeset.id, :name=>"newname"
      must_respond_with(:success)
      Changeset.find(@changeset.id).name.must_equal "newname"
    end

    it "should be able to check the status of a changeset being promoted" do

      @changeset.task_status = TaskStatus.create!(:organization_id =>@org.id, :uuid=>"FOO", :progress=>"0", :user=> users(:one))
      @changeset.save!
      get :changeset_status, :id=>@changeset.id
      must_respond_with(:success)
      response.body.must_include('changeset_' + @changeset.id.to_s)
    end

  end

  describe 'creating a changeset' do

    describe 'with only environment ids' do
      it 'should create a changeset correctly and send a notification' do
        must_notify_with(:success)
        post 'create', {:changeset => {:name => "Changeset 7055"}, :next_env_id => @next_env.id}
        must_respond_with(:success)
        PromotionChangeset.exists?(:name => 'Changeset 7055').must_equal(true)
      end
    end

    describe 'with a next environment id' do
      it 'should create a changeset correctly and send a notification' do
        must_notify_with(:success)
        post 'create', {:changeset => {:name => "Changeset 7055"}, :next_env_id => @next_env.id}
        must_respond_with(:success)
        PromotionChangeset.exists?(:name=>'Changeset 7055').must_equal(true)
      end
    end

    describe 'with a deletion type' do
      it 'should create a changeset correctly and send a notification' do
        must_notify_with(:success)
        post 'create', {:changeset => {:name => "Changeset 7056", :description => "FOO", :action_type => Changeset::DELETION}, :env_id => @env.id}
        must_respond_with(:success)
        DeletionChangeset.exists?(:name => "Changeset 7056").must_equal(true)
      end
    end

    describe 'with a promotion type' do
      it 'should create a changeset correctly and send a notification' do
        must_notify_with(:success)
        post 'create', {:changeset => {:name => "Changeset 7056", :description => "FOO", :action_type => Changeset::PROMOTION}, :env_id => @env.id, :next_env_id => @next_env.id}
        must_respond_with(:success)
        PromotionChangeset.exists?.must_equal(true)
      end
    end

    describe 'with a description' do
      it 'should create a changeset correctly and send a notification' do
        must_notify_with(:success)
        post 'create', {:changeset => {:name => "Changeset 7056", :description => "FOO"}, :next_env_id => @next_env.id}
        must_respond_with(:success)
        PromotionChangeset.exists?(:description=>'FOO').must_equal(true)
      end
    end

    it 'should cause an error notification if name is left blank' do
      must_notify_with(:exception)
      post 'create', {:env_id => @env.id, :next_env_id => @next_env.id, :changeset => {:name => ''}}
      response.must_respond_with(422)
    end

    it 'should cause an error notification if no environment id is present' do
      must_notify_with(:error)
      post 'create', {:changeset => { :name => 'Test/Changeset 4.5'}}
      response.must_respond_with(406)
    end

  end

  describe 'deleting a changeset' do
    before (:each) do
      @changeset = PromotionChangeset.create(CSControllerTest::CHANGESET)
    end

    it 'should successfully delete a changeset' do
      must_notify_with(:success)
      delete 'destroy', :id=>@changeset.id
      must_respond_with(:success)
      Changeset.exists?(:id=>@changeset.id).must_equal(false)
    end

    it 'should raise an exception if no such changeset exists' do
      must_notify_with(:error)
      delete 'destroy', :id=>20
      response.must_respond_with(404)
      Changeset.exists?(:id=>@changeset.id).must_equal(true)
    end
  end

  describe 'updating a changeset' do
    before (:each) do
      @changeset = PromotionChangeset.create!(CSControllerTest::CHANGESET)
    end

    it 'should successfully update a changeset' do
      put 'update', {:id=>@changeset.id, :name=> 'newname'}
      must_respond_with(:success)
      response.headers.must_include("X-ChangesetUsers")
      Changeset.exists?(:name=>'newname').must_equal(true)
    end

    it 'should not have a changeset user for name-only updates ' do
      put 'update', {:id=>@changeset.id, :name=> 'anothername'}
      must_respond_with(:success)
      @changeset.users.length.must_equal 0
    end
  end

  describe "rules" do
    before (:each) do
      @organization = new_test_org
      @env1 = @organization.library
      @env2 = create_environment(:name=>"FOO", :label=> "FOO", :prior => @env1, :organization=>@organization)
      @env3 = create_environment(:name=>"FOO2", :label=> "FOO2", :prior => @env2, :organization=>@organization)
      @cs = PromotionChangeset.create!(:name=>"FOO", :environment=>@env3, :state=>"promoted")
    end

    describe "GET index" do
      let(:action) {:items}
      let(:req) { get :items, :env_id=>@env3.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read_changesets, :environments, @env3.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end

      let(:before_success) do
        @controller.expects(:render_panel_direct)
        @controller.stubs(:render)
      end
      it_should_behave_like "protected action"
    end

    describe "POST update" do
      let(:action) {:update}
      let(:req) { post 'update', :id=>@cs.id, :name=>"apples" }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:manage_changesets, :environments, @env3.id, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read_changesets, :environments, @env3.id, @organization) }
      end
      let(:on_success) do
        assigns(:environment).must_equal @env3
      end
      it_should_behave_like "protected action"
    end

    describe "POST apply" do
      before do
        @cs2 = PromotionChangeset.create(:name=>"FOO2", :environment=>@env2, :state=>"review")
      end
      let(:action) {:apply}
      let(:req) do
        post 'apply', :id=>@cs2.id
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:promote_changesets, :environments, @env2.id, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:delete_changesets, :environments, @env2.id, @organization) }
        user_with_permissions { |u| u.can(:read_changesets, :environments, @env2.id, @organization) }
        user_with_permissions { |u| u.can(:manage_changesets, :environments, @env2.id, @organization) }
      end

      it_should_behave_like "protected action"
    end

    describe "POST Deletion apply" do
      before do
        @cs2 = DeletionChangeset.create(:name=>"FOO2", :environment=>@env2, :state=>"review")
      end
      let(:action) {:apply}
      let(:req) do
        post 'apply', :id=>@cs2.id
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:delete_changesets, :environments, @env2.id, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:promote_changesets, :environments, @env2.id, @organization) }
        user_with_permissions { |u| u.can(:read_changesets, :environments, @env2.id, @organization) }
        user_with_permissions { |u| u.can(:manage_changesets, :environments, @env2.id, @organization) }
      end

      it_should_behave_like "protected action"
    end

  end
  end

end
end
