# encoding: utf-8
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

require "katello_test_helper"

module Katello
  describe Api::V1::CandlepinProxiesController do

    before do
      models = ["Organization", "KTEnvironment", "User", "ContentViewFilter",
                "ContentViewEnvironment", "System", "HostCollection", "ActivationKey"]
      disable_glue_layers(["Candlepin", "ElasticSearch"], models)
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @system = katello_systems(:simple_server)
      @organization = get_organization
    end

    describe "register with activation key"  do
      it "should fail without specifying owner (organization)" do
        post('consumer_activate', :activation_keys => 'non_existent_key')
        assert_response 404
      end

      it "should fail with unknown organization" do
        post('consumer_activate', :owner => 'not_an_organization', :activation_keys => 'non_existent_key')
        assert_response 404
      end

      it "should fail with known organization and no activation_keys" do
        post('consumer_activate', :owner => @organization.name, :activation_keys => '')
        assert_response 400
      end
    end

    describe "update enabled_repos", :katello => true do
      before do
        User.stubs(:consumer?).returns(true)
        System.stubs(:first).returns(@system)
        uuid = @system.uuid
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid, :remote_id => uuid))
        Repository.stubs(:where).with(:relative_path=>'foo').returns([OpenStruct.new({ :pulp_id => 'a' })])
        Repository.stubs(:where).with(:relative_path=>'bar').returns([OpenStruct.new({ :pulp_id => 'b' })])
        System.any_instance.stubs(:generate_applicability)
      end
      let(:enabled_repos) {
        {
            "repos" => [
                {
                    "baseurl" => ["https://hostname/pulp/repos/foo"],
                },
                {
                    "baseurl" => ["https://hostname/pulp/repos/bar"],
                },
            ]
        }
      }
      let(:enabled_repos_empty) { { "repos" => [] } }

      it "should not bind any" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).returns(
            [{ 'repo_id' => 'a', 'type_id' =>'yum_distributor' }, { 'repo_id' => 'b', 'type_id' => 'yum_distributor'}])

        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
        assert_equal 200, response.status
      end

      it "should bind one" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).returns(
            [{ 'repo_id' => 'a', 'type_id' => 'yum_distributor' }])
        Katello.pulp_server.extensions.consumer.expects(:bind_all).with(@system.uuid, 'b', "yum_distributor", {:notify_agent=>false}).returns([])
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
        assert_equal 200, response.status
      end

      it "should bind two" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).returns({})
        Katello.pulp_server.extensions.consumer.expects(:bind_all).with(@system.uuid, 'a', "yum_distributor", {:notify_agent=>false}).returns([])
        Katello.pulp_server.extensions.consumer.expects(:bind_all).with(@system.uuid, 'b', "yum_distributor", {:notify_agent=>false}).returns([])
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
        assert_equal 200, response.status
      end

      it "should bind one and unbind one" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).returns(
            [{ 'repo_id' => 'b', 'type_id' =>'yum_distributor' }, { 'repo_id' => 'c', 'type_id' =>'yum_distributor' }])
        Katello.pulp_server.extensions.consumer.expects(:bind_all).with(@system.uuid, 'a', "yum_distributor", {:notify_agent=>false}).returns([])
        Katello.pulp_server.extensions.consumer.expects(:unbind_all).with(@system.uuid, 'c', 'yum_distributor').returns([])
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
        assert_equal 200, response.status
      end

      it "should unbind two" do

        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).returns(
            [{ 'repo_id' => 'a', 'type_id' =>'yum_distributor' }, { 'repo_id' => 'b', 'type_id' =>'yum_distributor' }])
        Katello.pulp_server.extensions.consumer.expects(:unbind_all).with(@system.uuid, 'a', 'yum_distributor').returns([])
        Katello.pulp_server.extensions.consumer.expects(:unbind_all).with(@system.uuid, 'b', 'yum_distributor').returns([])
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos_empty
        assert_equal 200, response.status
      end

      it "should do nothing" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).returns({})
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos_empty
        assert_equal 200, response.status
      end
    end

    describe "list owners" do

      it 'should return organizations admin user is assigned to' do
        User.current = User.find(users(:admin))
        get :list_owners, :login => User.current.login

        assert_empty (JSON.parse(response.body).collect { |org| org['displayName'] } - Organization.pluck(:name))
      end

      it 'should return organizations user is assigned to' do
        setup_current_user_with_permissions(:my_organizations)

        get :list_owners, :login => User.current.login
        assert_equal JSON.parse(response.body).first['displayName'], taxonomies(:empty_organization).name
      end

      it "should protect list owners with authentication" do
        get :list_owners, :login => User.current.login
        assert_response 200
      end

      it "should prevent listing owners for unauthenticated requests" do
        User.current = nil
        session[:user] = nil
        get :list_owners, :login => 100
        assert_response 401
      end
    end

    it "test_list_owners_protected" do
      assert_protected_action(:list_owners, :my_organizations) do
        get :list_owners, :login => User.current.login
      end
    end

    it "test_rhsm_index_protected" do
      assert_protected_action(:rhsm_index, :view_lifecycle_environments) do
        get :rhsm_index, :organization_id => @organization.label
      end
    end

    it "test_consumer_create_protected" do
      assert_protected_action(:consumer_create, [[:create_content_hosts,
                    :view_lifecycle_environments, :view_content_views]]) do
        post :consumer_create, :environment_id => @organization.library.content_view_environments.first.cp_id
      end
    end

    it "test_upload_package_profile_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:upload_package_profile, :edit_content_hosts) do
        put :upload_package_profile, :id => @system.uuid
      end
    end

    it "test_regenerate_identity_certificates_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:regenerate_identity_certificates, :edit_content_hosts) do
        post :regenerate_identity_certificates, :id => @system.uuid
      end
    end

    it "test_hypervisors_update" do
      assert_protected_action(:hypervisors_update, :edit_content_hosts) do
        post :hypervisors_update, :env => @organization.library.content_view_environments.first.label
      end
    end

    describe "available releases" do

      it "can be listed by matching consumer" do
        # Stub out the current user to simulate consumer auth.
        uuid = @system.uuid
        User.stubs(:consumer?).returns(true)
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid, :remote_id => uuid))

        get :available_releases, :id => @system.uuid
        assert_response 200      
      end

      it "forbidden with invalid consumer" do
        # Stub out the current user to simulate consumer auth.
        uuid = 4444
        User.stubs(:consumer?).returns(true)
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid, :remote_id => uuid))
        # Getting the available releases for a different consumer
        # should not be allowed.
        get :available_releases, :id => @system.uuid
        assert_response 403
      end
    end

  end
end
