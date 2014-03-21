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
describe Api::V1::SyncController do
  include OrchestrationHelper
  include OrganizationHelperMethods
  include ProductHelperMethods
  include RepositoryHelperMethods
  include AuthorizationHelperMethods

  let(:provider_id) { "123" }
  let(:product_id) { "123" }
  let(:repository_id) { "123" }
  let(:async_task_1) do
    { "href"          => "/pulp/api/v2/task_groups/a4e8579d-6c41-4134-a150-cf65faeafdfe/",
      "response"      => "postponed",
      "reasons"       => [],
      "state"         => "waiting",
      "task_id"       => "123",
      "task_group_id" => "a4e8579d-6c41-4134-a150-cf65faeafdfe",
      "schedule_id"   => nil,
      "progress"      => {},
      "result"        => nil,
      "exception"     => nil,
      "traceback"     => nil,
      "start_time"    => DateTime.now,
      "finish_time"   => DateTime.now,
      "tags"          => ["pulp:action:sync", "pulp:repository:repo_id"] }
  end
  let(:async_task_2) do
    { "href"          => "/pulp/api/v2/task_groups/a4e8579d-6c41-4134-a150-cf65faeafdfe/",
      "response"      => "postponed",
      "reasons"       => [],
      "state"         => "waiting",
      "task_id"       => "456",
      "task_group_id" => "a4e8579d-6c41-4134-a150-cf65faeafdfe",
      "schedule_id"   => nil,
      "progress"      => {},
      "result"        => nil,
      "exception"     => nil,
      "traceback"     => nil,
      "start_time"    => DateTime.now,
      "finish_time"   => DateTime.now,
      "tags"          => ["pulp:action:sync", "pulp:repository:repo_id_2"] }
  end

  describe "(katello)" do

  before(:each) do
    setup_controller_defaults_api
    disable_org_orchestration
  end

  describe "rules" do
    before(:each) do
      stub_product_with_repo
    end
    describe "for provider index" do
      let(:action) { :index }
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
      let(:action) { :index }
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
      let(:action) { :index }
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
      let(:action) { :create }
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
      let(:action) { :cancel }
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

      subject { @controller.send(:find_object) }

      it "should find provider if :provider_id is specified" do
        found_provider = {}
        Provider.expects(:find).once.with(provider_id).returns(found_provider)
        @controller.stubs(:params).returns({ :provider_id => provider_id })

        subject.must_equal found_provider
      end

      it "should find product if :product_id is specified" do
        stub_product_with_repo
        @controller.stubs(:params).returns({ :organization_id => @organization.label, :product_id => @product.id })
        @controller.send(:find_optional_organization)
        subject.must_equal @product
      end

      it "should find repository if :repository_id is specified" do
        found_repository = Repository.new
        found_repository.stubs(:environment).returns(KTEnvironment.new(:library => true))

        Repository.expects(:find).once.with(repository_id).returns(found_repository)
        @controller.stubs(:params).returns({ :repository_id => repository_id })

        subject.must_equal found_repository
      end

      it "should raise an error if none were specified" do
        lambda { subject }.must_raise(HttpErrors::NotFound)
      end
    end

    describe "start a sync" do
      before(:each) do
        stub_product_with_repo

        Katello.pulp_server.extensions.repository.stubs(:sync).with(@repository.pulp_id, anything()).returns([async_task_1])
        Katello.pulp_server.extensions.repository.stubs(:sync).with(@repository2.pulp_id, anything()).returns([async_task_2])
      end

      it "should find provider" do
        Provider.expects(:find).once.with(provider_id).returns(@provider)
        post :create, :provider_id => provider_id
      end

      it "should call sync on the object of synchronization" do
        @provider.expects(:sync).once.returns([async_task_1, async_task_2])
        post :create, :provider_id => provider_id
      end

      it "should persist all sync objects" do
        count = PulpTaskStatus.all.count
        post :create, :provider_id => provider_id

        found = PulpTaskStatus.all
        found.size.must_equal count + 2
        found.any? { |t| t['uuid'] == async_task_1['task_id'] }.must_equal true
        found.any? { |t| t['uuid'] == async_task_2['task_id'] }.must_equal true
      end

      it "should return sync objects" do
        post :create, :provider_id => provider_id

        status = JSON.parse(response.body)
        status.size.must_equal 2
        status.any? { |s| s['uuid'] == async_task_1['task_id'] }.must_equal true
        status.any? { |s| s['uuid'] == async_task_2['task_id'] }.must_equal true
      end
    end

    describe "cancel a sync" do
      before(:each) do
        @organization = Organization.create!(:name => "organization", :label => "123")

        @syncable = mock('syncable')
        @syncable.stubs(:id)
        @syncable.stubs(:cance_sync)
        @syncable.stubs(:organization).returns(@organization)
        @syncable.stubs(:sync)

        Provider.stubs(:find).returns(@syncable)
      end

      it "should find provider" do
        Provider.expects(:find).once.with(provider_id).returns(@syncable)
        post :create, :provider_id => provider_id
      end

      it "should call cancel_sync on the object of synchronization" do
        @syncable.stubs(:sync_state).returns(PulpSyncStatus::Status::RUNNING)
        @syncable.expects(:cancel_sync)
        delete :cancel, :provider_id => provider_id
      end

      it "should not call cancel_sync when the object is not being synchronized" do
        @syncable.stubs(:sync_state).returns(PulpSyncStatus::Status::FINISHED)
        @syncable.expects(:cancel_sync).never
        delete :cancel, :provider_id => provider_id
      end

    end

    describe "get status of last sync" do
      before(:each) do
        @organization = Organization.create!(:name => "organization", :label => "123")

        @syncable = mock()
        @syncable.stubs(:latest_sync_statuses).returns([async_task_1, async_task_2])
        @syncable.stubs(:organization).returns(@organization)
        @syncable.stubs(:sync)

        Provider.stubs(:find).returns(@syncable)
      end

      it "should find provider" do
        Provider.expects(:find).once.with(provider_id).returns(@syncable)
        post :create, :provider_id => provider_id
      end

      it "should call latest_sync_statuses on the object of synchronization" do
        @syncable.expects(:sync_status)
        get :index, :provider_id => provider_id
      end
    end
  end

  def stub_product_with_repo
    disable_product_orchestration

    @organization = new_test_org

    @provider = Provider.create!(:provider_type => Provider::CUSTOM, :name => "foo1", :organization => @organization)
    Provider.stubs(:find).returns(@provider)
    @product          = Product.new({ :name => "prod", :label => "prod" })
    @product.provider = @provider
    @product.stubs(:arch).returns('noarch')
    @product.save!
    Product.stubs(:find).returns(@product)
    Product.stubs(:find_by_cp_id).returns(@product)
    @repository  = new_test_repo(@organization.library, @product, "repo_1", "#{@organization.name}/Library/prod/repo")
    @repository2 = new_test_repo(@organization.library, @product, "repo_2", "#{@organization.name}/Library/prod/repo")

    Repository.stubs(:find).returns(@repository)
  end

  end

end
end
