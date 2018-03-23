# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::EnvironmentsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    def models
      @organization = get_organization
      @library = katello_environments(:library)
      @staging = katello_environments(:staging)
    end

    def permissions
      @resource_type = "Katello::KTEnvironment"
      @view_permission = :view_lifecycle_environments
      @create_permission = :create_lifecycle_environments
      @update_permission = :edit_lifecycle_environments
      @destroy_permission = :destroy_lifecycle_environments
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      Katello::PuppetModule.stubs(:module_count).returns(0)
      models
      permissions
    end

    def test_create
      Organization.any_instance.stubs(:save!).returns(@organization)
      name = 'dev env'
      label = 'dev_env'
      description = 'This environment is for development.'
      post :create, params: { :organization_id => @organization.id, :environment => {
        :name => name,
        :label => label,
        :description => description,
        :prior => @library.id
      } }

      assert_response :success
      response = JSON.parse(@response.body)
      assert response.key?('name')
      assert_equal response['name'], name
      assert response.key?('label')
      assert_equal response['label'], label
      assert response.key?('description')
      assert_equal response['description'], description
    end

    def test_create_with_name
      Organization.any_instance.stubs(:save!).returns(@organization)
      env_name = 'dev env'
      assert_difference('KTEnvironment.count') do
        post :create, params: { :organization_id => @organization.id, :environment => {
          :name => env_name,
          :prior => @library.id
        } }
      end
      assert_response :success
      response = JSON.parse(@response.body)
      assert response.key?('name')
      assert_equal response['name'], env_name
    end

    def test_create_with_invalid_name
      assert_difference('KTEnvironment.count', 0) do
        post :create, params: { :organization_id => @organization.id, :environment => {
          :name => '',
          :prior => @library.id
        } }
      end
      assert_response :unprocessable_entity
    end

    def test_update_with_invalid_name
      put :update, params: { :organization_id => @organization.id, :id => @staging.id, :environment => {
        :name => ''
      } }
      assert_response :unprocessable_entity
    end

    def test_create_with_pattern
      Organization.any_instance.stubs(:save!).returns(@organization)
      post :create, params: { :organization_id => @organization.id, :environment => {
        :name => 'dev env',
        :label => 'dev_env',
        :description => 'This environment is for development.',
        :prior => @library.id,
        :registry_name_pattern => '<%= repository.label %>'
      } }

      assert_response :success
    end

    def test_create_with_pattern_spaces
      Organization.any_instance.stubs(:save!).returns(@organization)
      post :create, params: { :organization_id => @organization.id, :environment => {
        :name => 'dev env',
        :label => 'dev_env',
        :description => 'This environment is for development.',
        :prior => @library.id,
        :registry_name_pattern => '<%= repository.label %> <%= lifecycle_environment.label %>'
      } }

      assert_response :success
    end

    def test_create_fail
      Organization.any_instance.stubs(:save!).returns(@organization)
      post :create, params: { :organization_id => @organization.id, :environment => {
        :description => 'This environment is for development.'
      } }

      assert_response :bad_request
    end

    def test_create_protected
      Organization.any_instance.stubs(:save!).returns(@organization)
      KTEnvironment.expects(:readable).returns(KTEnvironment)
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms, [@organization]) do
        post :create, params: { :organization_id => @organization.id, :environment => {
          :name => 'dev env',
          :label => 'dev_env',
          :description => 'This environment is for development.',
          :prior => @library.id
        } }
      end
    end

    def test_update
      original_label = @staging.label
      new_name = 'New Name'
      new_description = 'New environment description.'
      put :update, params: { :organization_id => @organization.id, :id => @staging.id, :environment => {
        :new_name => new_name,
        :label => 'New Label',
        :description => new_description
      } }

      assert_response :success
      assert_template 'api/v2/common/update'
      @staging.reload
      assert_equal new_name, @staging.name
      assert_equal new_description, @staging.description
      # note: label is not editable; therefore, confirm that it is unchanged
      assert_equal original_label, @staging.label
    end

    def test_update_pattern_async
      original_label = @staging.label

      assert_async_task(::Actions::Katello::Environment::PublishRepositories, @staging,
                        content_type: Katello::Repository::DOCKER_TYPE)
      put :update, params: {
        :organization_id => @organization.id, :id => @staging.id,
        :environment => {
          :new_name => 'New Name',
          :label => 'New Label',
          :registry_name_pattern => '<%= repository.label %>'
        }
      }

      assert_response :success
      assert_equal 'New Name', @staging.reload.name
      # note: label is not editable; therefore, confirm that it is unchanged
      assert_equal original_label, @staging.label
    end

    def test_update_pattern_sync
      original_label = @staging.label

      assert_sync_task(::Actions::Katello::Environment::PublishRepositories, @staging,
                        content_type: Katello::Repository::DOCKER_TYPE)
      put :update, params: {
        :organization_id => @organization.id, :id => @staging.id,
        :async => false,
        :environment => {
          :new_name => 'New Name',
          :label => 'New Label',
          :registry_name_pattern => '<%= repository.label %>'
        }
      }

      assert_response :success
      assert_equal 'New Name', @staging.reload.name
      # note: label is not editable; therefore, confirm that it is unchanged
      assert_equal original_label, @staging.label
    end

    def test_update_pattern_spaces
      put :update, params: { :organization_id => @organization.id, :id => @staging.id, :environment => {
        :new_name => 'New Name',
        :label => 'New Label',
        :registry_name_pattern => '<%= repository.label %> <%= organization.label %>'
      } }

      assert_response :success
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@organization]) do
        put :update, params: { :organization_id => @organization.id, :id => @staging.id, :environment => {
          :new_name => 'New Name'
        } }
      end
    end

    def test_index
      get :index, params: { :organization_id => @organization.id }

      assert_response :success
    end

    def test_index_with_name
      get :index, params: { :organization_id => @organization.id, :name => @organization.library.name }

      assert_response :success
    end

    def test_destroy
      destroyable_env = KTEnvironment.create!(:name => "DestroyAble",
                                              :organization => @staging.organization,
                                              :prior => @staging)
      assert_sync_task(::Actions::Katello::Environment::Destroy, destroyable_env)
      delete :destroy, params: { :organization_id => @organization.id, :id => destroyable_env.id }

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@view_permission, @update_permission, @create_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@organization]) do
        delete :destroy, params: { :organization_id => @organization.id, :id => @staging.id }
      end
    end

    def test_paths
      get :paths, params: { :organization_id => @organization.id }

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/collection'
      assert_template 'api/v2/environments/paths'
    end

    def test_paths_protected
      allowed_perms = [@view_permission]
      denied_perms = [@destroy_permission, @update_permission, @create_permission]

      assert_protected_action(:paths, allowed_perms, denied_perms, [@organization]) do
        get :paths, params: { :organization_id => @organization.id }
      end
    end
  end
end
