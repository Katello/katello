# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::OrganizationsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    include Support::ForemanTasks::Task

    def permissions
      @read_permission = :view_organizations
      @create_permission = :create_organizations
      @update_permission = :edit_organizations
      @delete_permission = :destroy_organizations
    end

    def models
      @organization = get_organization
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      Organization.any_instance.stubs(:service_levels)
      Organization.any_instance.stubs(:service_level)
      Organization.any_instance.stubs(:owner_details).returns({})
      models
      permissions
    end

    def test_index
      results = JSON.parse(get(:index).body)

      assert_response :success
      assert_template 'api/v2/organizations/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @delete_permission, @update_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index
      end
    end

    def test_show
      results = JSON.parse(get(:show, params: { :id => @organization.id }).body)
      assert_response :success

      assert_equal results['name'], @organization.name
      assert_template 'api/v2/organizations/show'
    end

    def test_show_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @delete_permission, @update_permission]

      assert_protected_action(:show, allowed_perms, denied_perms, [@organization]) do
        get :show, params: { :id => @organization.id }
      end
    end

    def test_create_with_exception
      post(:create, params: { :organization => { name: "test_cli_org", description: "desc", smart_proxy_ids: ["2"], domain_ids: ["1"], subnet_ids: ["1", "2"]} })
      assert_match Regexp.new("Couldn't find"), response.body
    end

    def test_create_duplicate_name
      post(:create, params: { :organization => {"name" => @organization.name} })
      assert_response :unprocessable_entity
    end

    def test_controller_path
      get :show, params: { :id => @organization.id }
      assert_response :success
      assert_equal "/katello/api/organizations/#{@organization.id}", @request.fullpath
    end

    def test_delete
      assert_async_task ::Actions::Katello::Organization::Destroy do |org|
        org.id.must_equal @organization.id
      end
      delete(:destroy, params: { :id => @organization.id })

      assert_response :success
    end

    def test_delete_protected
      allowed_perms = [@delete_permission]
      denied_perms = [@create_permission, @read_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@organization]) do
        delete :destroy, params: { :id => @organization.id }
      end
    end

    def test_update_redhat_repo_url
      #stub foreman super class..
      ::Api::V2::TaxonomiesController.class_eval do
        def params_match_database
        end
      end

      url = "http://www.redhat.com"
      assert_sync_task ::Actions::Katello::Provider::Update do |_organization, params|
        params[:redhat_repository_url] == url
      end

      put(:update, params: { :id => @organization.id, :redhat_repository_url => url })
      assert_response :success
    end

    def test_update_description
      new_description = "this is a new exciting description"
      put :update, params: { :id => @organization.id, :organization => { :description => new_description } }

      @organization.reload
      assert_response :success
      assert_equal new_description, @organization.description
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@create_permission, @read_permission, @delete_permission]

      assert_protected_action(:update, allowed_perms, denied_perms, [@organization]) do
        put :update, params: { :id => @organization.id, :organization => {:name => 'NewName'} }
      end
    end

    def test_autoattach_subscriptions
      assert_async_task ::Actions::Katello::Organization::AutoAttachSubscriptions do |organization|
        organization.id == @organization.id
      end

      post :autoattach_subscriptions, params: { :id => @organization.id }

      assert_response :success
    end

    def test_autoattach_subscriptions_protected
      allowed_perms = [@update_permission]
      assert_protected_action(:autoattach_subscriptions, allowed_perms, [], [@organization]) do
        post :autoattach_subscriptions, params: { :id => @organization.id }
      end
    end

    def test_releases
      results = JSON.parse(get(:releases, params: { :id => @organization.id }).body)

      assert_response :success
      assert_template "katello/api/v2/common/releases"

      assert_empty ['results', 'subtotal', 'total'] - results.keys
    end

    def test_available_releases_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @delete_permission, @update_permission]

      assert_protected_action(:releases, allowed_perms, denied_perms, [@organization]) do
        get :releases, params: { :id => @organization.id }
      end
    end

    context "create_organization" do
      setup do
        Organization.any_instance.stubs(:redhat_repository_url)
        Organization.any_instance.stubs(:default_content_view).returns(OpenStruct.new(id: 1))
        Organization.any_instance.stubs(:library).returns(OpenStruct.new(id: 10))
      end

      def test_create
        name = "Michaelangelo"
        assert_sync_task ::Actions::Katello::Organization::Create do |org|
          org.name.must_equal name
          org.stubs(:reload)
        end
        post(:create, params: { :organization => {"name" => name} })
        assert_response :success
      end

      test_attributes :pid => 'c9f69ee5-c6dd-4821-bb05-0d93ffa22460'
      def test_create_with_auto_label
        name = "Organization With Label"
        assert_sync_task ::Actions::Katello::Organization::Create do |org|
          org.name.must_equal name
          assert org.valid?
          assert_equal org.label, name.gsub(' ', '_')
          org.stubs(:reload)
        end
        post :create, params: { :organization => {:name => name} }
        assert_response :success
      end

      test_attributes :pid => '2bdd9aa8-a36a-4009-ac29-5c3d6416a2b7'
      def test_create_with_name_and_label
        name = "Organization With Label"
        label = "org_with_label"
        assert_sync_task ::Actions::Katello::Organization::Create do |org|
          org.name.must_equal name
          org.label.must_equal label
          assert org.valid?
          org.stubs(:reload)
        end
        post :create, params: { :organization => {:name => name, :label => label} }
        assert_response :success
      end

      def test_create_with_name_description_auto_label
        name = "Organization With Name Description Auto Label"
        description = "Organization Description"
        assert_sync_task ::Actions::Katello::Organization::Create do |org|
          org.name.must_equal name
          org.description.must_equal description
          assert org.valid?
          assert_equal org.label, name.gsub(' ', '_')
          org.stubs(:reload)
        end
        post :create, params: { :organization => {:name => name, :description => description} }
        assert_response :success
      end

      test_attributes :pid => 'f7d92392-751e-45de-91da-5ed2a47afc3f'
      def test_create_with_name_label_description
        name = "Organization With Name Label Description"
        label = "organization_with_name_label_description"
        description = "Organization Description"
        assert_sync_task ::Actions::Katello::Organization::Create do |org|
          org.name.must_equal name
          org.label.must_equal label
          org.description.must_equal description
          assert org.valid?
          org.stubs(:reload)
        end
        post :create, params: { :organization => {:name => name, :label => label, :description => description} }
        assert_response :success
      end
    end
  end
end
