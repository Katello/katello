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

require 'spec_helper'
include OrchestrationHelper

describe Api::SyncController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include ProductHelperMethods
  include RepositoryHelperMethods
  include AuthorizationHelperMethods

  let(:provider_id) { "123" }
  let(:product_id) { "123" }
  let(:repository_id) { "123" }
  let(:async_task_1) do
    { "href" => "/pulp/api/v2/task_groups/a4e8579d-6c41-4134-a150-cf65faeafdfe/",
      "response" => "postponed",
      "reasons" => [],
      "state" => "waiting",
      "task_id" => "123",
      "task_group_id" => "a4e8579d-6c41-4134-a150-cf65faeafdfe",
      "schedule_id" => nil,
      "progress" => {},
      "result" => nil,
      "exception" => nil,
      "traceback" => nil,
      "start_time" => DateTime.now,
      "finish_time" => DateTime.now,
      "tags" => ["pulp:action:sync", "pulp:repository:repo_id"] }
  end
  let(:async_task_2) do
    { "href" => "/pulp/api/v2/task_groups/a4e8579d-6c41-4134-a150-cf65faeafdfe/",
      "response" => "postponed",
      "reasons" => [],
      "state" => "waiting",
      "task_id" => "456",
      "task_group_id" => "a4e8579d-6c41-4134-a150-cf65faeafdfe",
      "schedule_id" => nil,
      "progress" => {},
      "result" => nil,
      "exception" => nil,
      "traceback" => nil,
      "start_time" => DateTime.now,
      "finish_time" => DateTime.now,
      "tags" => ["pulp:action:sync", "pulp:repository:repo_id_2"] }
  end

  before(:each) do
    login_user
    set_default_locale
    disable_org_orchestration
  end

  describe "rules" do
    before(:each) do
      stub_product_with_repo
    end
    describe "for provider index" do
      let(:action) {:index}
      let(:req) do
        get :index, :provider_id => provider_id
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
    describe "for product index" do
      let(:action) {:index}
      let(:req) do
        get :index, :product_id => product_id, :organization_id => @organization.label
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
    describe "for repository index" do
      let(:action) {:index}
      let(:req) do
        get :index, :repository_id => repository_id
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
    describe "for create" do
      let(:action) {:create}
      let(:req) do
        post :create, :provider_id => provider_id
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:sync, :organizations, @organization.id) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
    describe "for cancel" do
      let(:action) {:cancel}
      let(:req) do
        post :cancel, :provider_id => provider_id
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:sync, :organizations, @organization.id) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  describe "test" do
    before(:each) do
      disable_authorization_rules
    end

    describe "find_object" do

      subject { controller.send(:find_object) }

      it "should find provider if :provider_id is specified" do
        found_provider = {}
        Provider.should_receive(:find).once.with(provider_id).and_return(found_provider)
        controller.stub!(:params).and_return({:provider_id => provider_id })

        subject.should == found_provider
      end

      it "should find product if :product_id is specified" do
        stub_product_with_repo
        controller.stub!(:params).and_return({:organization_id => @organization.label, :product_id => @product.id })

        subject.should == @product
      end

      it "should find repository if :repository_id is specified" do
        found_repository = Repository.new
        found_repository.stub!(:environment).and_return(KTEnvironment.new(:library => true))

        Repository.should_receive(:find).once.with(repository_id).and_return(found_repository)
        controller.stub!(:params).and_return({:repository_id => repository_id })

        subject.should == found_repository
      end

      it "should raise an error if none were specified" do
        lambda { subject }.should raise_error(HttpErrors::NotFound)
      end
    end

    describe "start a sync" do
      before(:each) do
        stub_product_with_repo

        Runcible::Extensions::Repository.stub(:sync).with(@repository.pulp_id, anything()).and_return([async_task_1])
        Runcible::Extensions::Repository.stub(:sync).with(@repository2.pulp_id, anything()).and_return([async_task_2])
      end

      it "should find provider" do
        Provider.should_receive(:find).once.with(provider_id).and_return(@provider)
        post :create, :provider_id => provider_id
      end

      it "should call sync on the object of synchronization" do
         @provider.should_receive(:sync).once.and_return([async_task_1, async_task_2])
         post :create, :provider_id => provider_id
      end

      it "should persist all sync objects" do
        count = PulpTaskStatus.all.count
        post :create, :provider_id => provider_id

        found = PulpTaskStatus.all
        found.size.should ==  count + 2
        found.any? {|t| t['uuid'] == async_task_1['task_id']} .should == true
        found.any? {|t| t['uuid'] == async_task_2['task_id']} .should == true
      end

      it "should return sync objects" do
        post :create, :provider_id => provider_id

        status = JSON.parse(response.body)
        status.size.should == 2
        status.any? {|s| s['uuid'] == async_task_1['task_id']} .should == true
        status.any? {|s| s['uuid'] == async_task_2['task_id']} .should == true
      end
    end

    describe "cancel a sync" do
      before(:each) do
        @organization = Organization.create!(:name=>"organization", :label=> "123")

        @syncable = mock('syncable')
        @syncable.stub!(:id)
        @syncable.stub!(:cance_sync)
        @syncable.stub!(:organization).and_return(@organization)
        @syncable.stub!(:sync)

        Provider.stub!(:find).and_return(@syncable)
      end

      it "should find provider" do
        Provider.should_receive(:find).once.with(provider_id).and_return(@syncable)
        post :create, :provider_id => provider_id
      end

      it "should call cancel_sync on the object of synchronization" do
         @syncable.stub(:sync_state).and_return(PulpSyncStatus::Status::RUNNING)
         @syncable.should_receive(:cancel_sync)
         delete :cancel, :provider_id => provider_id
      end

      it "should not call cancel_sync when the object is not being synchronized" do
        @syncable.stub(:sync_state).and_return(PulpSyncStatus::Status::FINISHED)
        @syncable.should_not_receive(:cancel_sync)
         delete :cancel, :provider_id => provider_id
      end

    end


    describe "get status of last sync" do
      before(:each) do
        @organization = Organization.create!(:name=>"organization", :label => "123")

        @syncable = mock()
        @syncable.stub!(:latest_sync_statuses).once.and_return([async_task_1, async_task_2])
        @syncable.stub!(:organization).and_return(@organization)
        @syncable.stub!(:sync)

        Provider.stub!(:find).and_return(@syncable)
      end

      it "should find provider" do
        Provider.should_receive(:find).once.with(provider_id).and_return(@syncable)
        post :create, :provider_id => provider_id
      end

      it "should call latest_sync_statuses on the object of synchronization" do
         @syncable.should_receive(:sync_status)
         get :index, :provider_id => provider_id
      end
    end
  end

  def stub_product_with_repo
      disable_product_orchestration

      @organization = new_test_org

      @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      Provider.stub!(:find).and_return(@provider)
      @product = Product.new({:name=>"prod", :label=> "prod"})
      @product.provider = @provider
      @product.environments << @organization.library
      @product.stub(:arch).and_return('noarch')
      @product.save!
      Product.stub!(:find).and_return(@product)
      Product.stub!(:find_by_cp_id).and_return(@product)
      ep = EnvironmentProduct.find_or_create(@organization.library, @product)
      @repository = new_test_repo(ep, "repo_1", "#{@organization.name}/Library/prod/repo")
      @repository2 = new_test_repo(ep, "repo_2", "#{@organization.name}/Library/prod/repo")

      Repository.stub(:find).and_return(@repository)
  end

end

