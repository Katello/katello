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

describe ChangesetsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  module CSControllerTest

    ENV_NAME = "environment_name"
    ENVIRONMENT = {:name => ENV_NAME, :description => nil}
    NEXT_ENVIRONMENT = {:name => "next_env_name", :description => nil}
    CHANGESET = {:id=>1, :promotion_date=>Time.now, :name=>"oldname"}

  end

  before(:each) do
    login_user
    set_default_locale
    controller.stub!(:notice)
    controller.stub!(:errors)

    @org = new_test_org

    CSControllerTest::ENVIRONMENT["organization"] = @org
    CSControllerTest::ENVIRONMENT["prior"] = @org.locker.id
    @env = KTEnvironment.create!(CSControllerTest::ENVIRONMENT)
    CSControllerTest::NEXT_ENVIRONMENT["organization"] = @org
    @next_env = KTEnvironment.new(CSControllerTest::NEXT_ENVIRONMENT)
    @next_env.prior = @env;
    @next_env.save!

    CSControllerTest::CHANGESET["environment_id"] = @env.id
  end


  describe "viewing changesets" do
    before (:each) do
      @changeset = Changeset.create(CSControllerTest::CHANGESET)
    end

    it "should show the changeset 2 pane list" do
      get :index
      response.should be_success
    end

    it "changesetuser should be empty" do
      get :index
      @changeset.users.should be_empty
    end

    it "should return a portion of changesets for an environment" do
      get :items, :env_id=>@env.id
      response.should be_success
    end

    it "should be able to list changesets for an environment" do
      get :list, :env_id=>@env.id
      response.should be_success
    end

    it "should be able to show the edit partial" do
      get :edit, :id=>@changeset.id
      response.should be_success
    end

    it "should be able to update the name of a changeset" do
      post :update, :id=>@changeset.id, :name=>"newname"
      response.should be_success
      Changeset.find(@changeset.id).name.should == "newname"
    end

    it "should be able to check the progress of a changeset being promoted" do
      @changeset.task_status = TaskStatus.create!(:organization_id =>@org.id, :uuid=>"FOO", :progress=>"0")
      @changeset.save!
      get :promotion_progress, :id=>@changeset.id
      response.should be_success
      response.should contain('changeset_' + @changeset.id.to_s)
    end

  end

  describe 'creating a changeset' do

    describe 'with only an environment id' do
      it 'should create a changeset correctly and send a notification' do
        controller.should_receive(:notice)
        post 'create', {:name => "Changeset 7055", :env_id=>@env.id}
        response.should be_success
        Changeset.exists?(:name=>'Changeset 7055').should be_true
      end
    end

    describe 'with a next environment id' do
      it 'should create a changeset correctly and send a notification' do
        controller.should_receive(:notice)
        post 'create', {:name => "Changeset 7055", :env_id=>1, :next_env_id=>@next_env.id}
        response.should be_success
        Changeset.exists?(:name=>'Changeset 7055').should be_true
      end
    end

    describe 'with a description' do
      it 'should create a changeset correctly and send a notification' do
        controller.should_receive(:notice)
        post 'create', {:name => "Changeset 7056", :description=> "FOO", :env_id=>@env.id}
        response.should be_success
        Changeset.exists?(:description=>'FOO').should be_true
      end
    end



    it 'should cause an error notification if name is left blank' do
      controller.should_receive(:errors)
      post 'create', {:env_id => @env.id, :name => ''}
      response.should_not be_success
    end

    it 'should cause an exception if no environment id is present' do
      controller.should_receive(:errors)
      post 'create', {:changesets => { :name => 'Test/Changeset 4.5'}}
      response.should_not be_success
    end

    

  end

  describe 'deleting a changeset' do
    before (:each) do
      @changeset = Changeset.create(CSControllerTest::CHANGESET)
    end

    it 'should successfully delete a changeset' do
      controller.should_receive(:notice)
      delete 'destroy', :id=>@changeset.id
      response.should be_success
      Changeset.exists?(:id=>@changeset.id).should be_false
    end

    it 'should raise an exception if no such changeset exists' do
      controller.should_receive(:errors)
      delete 'destroy', :id=>20
      response.should_not be_success
      Changeset.exists?(:id=>@changeset.id).should be_true
    end
  end

  describe 'updating a changeset' do
    before (:each) do
      @changeset = Changeset.create!(CSControllerTest::CHANGESET)
    end

    it 'should successfully update a changeset' do
      put 'update', {:id=>@changeset.id, :name=> 'newname'}
      response.should be_success
      response.headers.should include("X-ChangesetUsers")
      Changeset.exists?(:name=>'newname').should be_true
    end

    it 'should not have a changeset user for name-only updates ' do
      put 'update', {:id=>@changeset.id, :name=> 'anothername'}
      response.should be_success
      @changeset.users.length.should == 0
    end
  end


  describe 'getting the dependencies of a changeset' do
    before (:each) do
      @changeset = Changeset.create!(CSControllerTest::CHANGESET)

    end

    it 'should call dependencies on the changeset' do
      @changeset.should_receive(:calc_dependencies).and_return({})
      Changeset.stub(:find).and_return(@changeset)
      get 'dependencies', {:id=>@changeset.id}
      response.should be_success
    end

  end

 describe "rules" do
    before (:each) do
      @organization = new_test_org
      @env1 = @organization.locker
      @env2 = KTEnvironment.create!(:name=>"FOO", :prior => @env1, :organization=>@organization)
      @env3 = KTEnvironment.create!(:name=>"FOO2", :prior => @env2, :organization=>@organization)
      @cs = Changeset.create!(:name=>"FOO", :environment=>@env3, :state=>"promoted")
    end

    describe "GET index" do
      let(:action) {:index}
      let(:req) { get 'index', :env_id=>@env3.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read_changesets, :environments, @env3.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      let(:on_success) do
        assigns(:changesets).should include @cs
        assigns(:environment).should == @env3
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
        assigns(:environment).should == @env3
      end
      it_should_behave_like "protected action"
    end

    describe "POST promote" do
      before do
        @cs2 = Changeset.create(:name=>"FOO2", :environment=>@env2, :state=>"review")
      end
      let(:action) {:promote}
      let(:req) do
        post 'promote', :id=>@cs2.id
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:promote_changesets, :environments, @env2.id, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read_changesets, :environments, @env2.id, @organization) }
        user_with_permissions { |u| u.can(:manage_changesets, :environments, @env2.id, @organization) }
      end

      it_should_behave_like "protected action"
    end
  end


end
