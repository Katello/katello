# encoding: utf-8

require "katello_test_helper"

# rubocop:disable Metrics/ClassLength
module Katello
  class Api::V2::ContentViewsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @library = KTEnvironment.find(katello_environments(:library).id)
      @dev = KTEnvironment.find(katello_environments(:dev).id)
      @staging = KTEnvironment.find(katello_environments(:staging).id)
      @library_dev_staging_view = ContentView.find(katello_content_views(:library_dev_staging_view).id)
      @library_dev_view = ContentView.find(katello_content_views(:library_dev_view).id)
      @library_solve_deps = katello_content_views(:library_view_solve_deps)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @publish_permission = :publish_content_views
    end

    def setup
      setup_controller_defaults_api
      ContentView.any_instance.stubs(:reindex_on_association_change).returns(true)
      ContentViewVersion.any_instance.stubs(:package_count).returns(0)
      ContentViewVersion.any_instance.stubs(:errata_count).returns(0)

      models
      permissions
      [:package_group_count, :package_count].each do |content_type_count|
        Repository.any_instance.stubs(content_type_count).returns(0)
      end
    end

    def test_index
      get :index, params: { :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/content_views/index'
    end

    def test_index_in_environment
      get :index, params: { :organization_id => @organization.id, :environment_id => @dev.id }

      assert_response :success
      assert_template 'api/v2/content_views/index'
    end

    def test_index_with_composite_filter
      get :index, params: { :organization_id => @organization.id, :composite => true }

      assert_response :success
      assert_template 'api/v2/content_views/index'
      views = JSON.parse(response.body)['results']
      assert views.length > 0
      assert views.all? { |view| view["composite"] }
    end

    def test_index_fail_without_organization_id
      get :index

      assert_response :success
      assert_template 'api/v2/content_views/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { :organization_id => @organization.id }
      end
    end

    test_attributes :pid => '80d36498-2e71-4aa9-b696-f0a45e86267f'
    def test_create
      post :create, params: { :name => "My View", :label => "My_View", :description => "Cool",
                              :organization_id => @organization.id, :solve_dependencies => true }

      assert_response :success
      assert_template :layout => 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_import
      post :create, params: { :name => "My View", :label => "My_View", :description => "Cool",
                              :organization_id => @organization.id, :import_only => true }

      assert_response :success
    end

    def test_publish_with_version_params
      target_view = ContentView.find(katello_content_views(:library_dev_view).id)

      assert_async_task ::Actions::Katello::ContentView::Publish do |view, description, params|
        assert_equal view, target_view
        assert_nil description
        assert_nil params[:force_metadata_generate]
        assert_equal params[:major], 4
        assert_equal params[:minor], 1
      end

      post :publish, params: { :id => target_view.id, :major => 4, :minor => 1 }
    end

    def test_publish_with_environment_id_params
      target_view = ContentView.find(katello_content_views(:library_dev_view).id)

      assert_async_task ::Actions::Katello::ContentView::Publish do |view, description, params|
        assert_equal view, target_view
        assert_nil description
        assert_nil params[:force_metadata_generate]
        assert_equal params[:environment_ids], [2]
      end

      post :publish, params: { :id => target_view.id, :environment_ids => [2] }
    end

    def test_create_fail_without_organization_id
      post :create, params: { :name => "My View", :label => "My_View", :description => "Cool" }

      assert_response :not_found
    end

    test_attributes :pid => '261376ca-7d12-41b6-9c36-5f284865243e'
    def test_should_not_create_with_empty_name
      post :create, params: { :name => '', :label => 'My_View', :description => 'Cool', :organization_id => @organization.id }
      assert_response :unprocessable_entity
      assert_match "Name can't be blank", @response.body
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:create, allowed_perms, denied_perms, [@organization]) do
        post :create, params: { :name => "Test", :organization_id => @organization.id }
      end
    end

    def test_create_protected_without_repo_read
      user = User.unscoped.find(users(:restricted).id)
      denied_perms = [@create_permission, @view_permission, @update_permission, :destroy_content_views]
      setup_user_with_permissions(denied_perms, user)
      repository = katello_repositories(:fedora_17_unpublished)
      login_user(user)

      post :create, params: {:organization_id => @organization.id, content_view: { :name => "Test", :repository_ids => [repository.id] } }

      assert_response 404
    end

    def test_create_protected_without_repo_read_non_wrapped
      user = User.unscoped.find(users(:restricted).id)
      denied_perms = [@create_permission, @view_permission, @update_permission, :destroy_content_views]
      setup_user_with_permissions(denied_perms, user)
      repository = katello_repositories(:fedora_17_unpublished)

      login_user(user)
      post :create, params: { :name => "Test", :organization_id => @organization.id, :repository_ids => [repository.id] }

      assert_response 404
    end

    def test_create_with_non_json_request
      @request.env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
      post :create, params: { :name => "My View", :description => "Cool", :organization_id => @organization.id }

      assert_response 415
    end

    def test_show
      get :show, params: { :id => @library_dev_staging_view.id }

      assert_response :success
      assert_template 'api/v2/content_views/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, params: { :id => @library_dev_staging_view.id }
      end
    end

    def test_show_protected_specific_instance
      allowed_perms = [{:name => :view_content_views, :search => "name=\"#{@library_dev_staging_view.name}\"" }]
      denied_perms = [{:name => :view_content_views, :search => "name=\"#{@library_dev_view.name}\"" }]

      assert_protected_object(:show, allowed_perms, denied_perms) do
        get :show, params: { :id => @library_dev_staging_view.id }
      end
    end

    test_attributes :pid => '3f1457f2-586b-472c-8053-99017c4a4909'
    def test_update
      params = { :name => "My View", :description => "New description", :solve_dependencies => true,
                 :auto_publish => false, :label => "test_label", :default => "test_default",
                 :created_at => "test_created_at", :updated_at => "test_updated_at", :composite => false,
                 :next_version => "test_next_version" }
      assert_sync_task(::Actions::Katello::ContentView::Update) do |_content_view, content_view_params|
        params.each do |key, value|
          if key == :label || key == :composite
            assert_equal content_view_params.key?(key), false
            assert_nil content_view_params[key]
          else
            assert_equal content_view_params.key?(key), true
            assert_equal content_view_params[key], value
          end
        end
      end
      put :update, params: { :id => @library_dev_staging_view.id, :content_view => params }

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_repositories
      repository = katello_repositories(:fedora_17_unpublished)

      params = { :repository_ids => [repository.id] }
      assert_sync_task(::Actions::Katello::ContentView::Update) do |_content_view, content_view_params|
        assert_equal content_view_params.key?(:repository_ids), true
        assert_equal content_view_params[:repository_ids], params[:repository_ids]
      end
      put :update, params: { :id => @library_dev_staging_view.id, :content_view => params }

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_repositories_strings
      repository = katello_repositories(:fedora_17_unpublished)

      params = { :repository_ids => [repository.id.to_s] }
      assert_sync_task(::Actions::Katello::ContentView::Update) do |_content_view, content_view_params|
        assert_equal content_view_params.key?(:repository_ids), true
        assert_equal content_view_params[:repository_ids], params[:repository_ids]
      end
      put :update, params: { :id => @library_dev_staging_view.id, :content_view => params }

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_components
      version = @library_dev_staging_view.versions.first
      composite = ContentView.find(katello_content_views(:composite_view).id)

      params = { :component_ids => [version.id] }
      assert_sync_task(::Actions::Katello::ContentView::Update) do |_content_view, content_view_params|
        assert_equal content_view_params.key?(:component_ids), true
        assert_equal content_view_params[:component_ids], params[:component_ids]
        assert_nil content_view_params[:repository_ids]
      end
      put :update, params: { :id => composite.id, :content_view => params }

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_duplicate_component_error_message
      view = katello_content_views(:library_view)
      view_version = create(:katello_content_view_version, :content_view => view, :major => 8999)

      composite = katello_content_views(:composite_view)
      ContentViewComponent.create!(:composite_content_view => composite,
                                   :content_view_version => view_version, :latest => false)

      view_version2 = create(:katello_content_view_version, :content_view => view, :major => 9001)

      put :update, params: { id: composite.id, content_view: { component_ids: [view_version.id, view_version2.id] } }
      display_message = JSON.parse(response.body)['displayMessage']
      test_message = "Validation failed: Base Another component already includes content view with ID #{view_version.content_view_id}"
      assert_equal test_message, display_message
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, :destroy_content_views]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, params: { :id => @library_dev_staging_view.id, :name => "new name" }
      end
    end

    test_attributes :pid => '69a2ce8d-19b2-49a3-97db-a1fdebbb16be'
    def test_should_not_update_with_empty_name
      put :update, params: { :id => @library_dev_staging_view.id, :content_view => { :name => '' } }
      assert_response :unprocessable_entity
      assert_match "Name can't be blank", @response.body
    end

    def test_publish_default_view
      view = ContentView.find(katello_content_views(:acme_default).id)
      version_count = view.versions.count
      post :publish, params: { :id => view.id }
      assert_response 400
      assert_equal version_count, view.versions.reload.count
    end

    def test_publish_composite_with_repos_units
      composite = ContentView.find(katello_content_views(:composite_view).id)
      post :publish, params: { :id => composite.id, :repos_units => "{\"hello\": 1}" }
      assert_response 400
    end

    test_attributes :pid => 'd582f1b3-8118-4e78-a639-237c6f9d27c6'
    def test_destroy
      view = ContentView.create!(:name => "Cat",
                                 :organization => @organization
                                )
      delete :destroy, params: { :id => view.id }
      assert_response :success
    end

    def test_remove_filters
      view = ContentView.create!(:name => "Cat",
                                 :organization => @organization
                                )
      filter = ContentViewFilter.create(:name => "CatFilter",
                                 :type => Katello::ContentViewPackageFilter.name,
                                 :content_view_id => view.id)
      put :remove_filters, params: { :id => view.id, :filter_ids => [filter.id] }
      assert_response :success
    end

    def test_publish_with_dup_params
      target_view = ContentView.find(katello_content_views(:library_dev_view).id)
      post :publish, params: { :id => target_view.id, :major => 1, :minor => 0 }
      assert_response 400
    end

    def test_publish_with_only_major
      target_view = ContentView.find(katello_content_views(:library_dev_view).id)
      post :publish, params: { :id => target_view.id, :major => 1 }
      assert_response 400
    end

    def test_publish_with_only_minor
      target_view = ContentView.find(katello_content_views(:library_dev_view).id)
      post :publish, params: { :id => target_view.id, :minor => 1 }
      assert_response 400
    end

    def test_destroy_protected
      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      diff_view_destroy_permission = {:name => :destroy_content_views, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [:destroy_content_views]
      denied_perms = [@view_permission, @create_permission, @update_permission, diff_view_destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, params: { :id => @library_dev_staging_view.id }
      end
    end

    test_attributes :pid => 'ee03dc63-e2b0-4a89-a828-2910405279ff'
    def test_copy
      post :copy, params: { :id => @library_dev_staging_view.id, :name => "My New View" }

      assert_response :success
      assert_template "katello/api/v2/content_views/copy"
    end

    def test_copy_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:copy, allowed_perms, denied_perms) do
        post :copy, params: { :id => @library_dev_staging_view.id, :name => "Test" }
      end
    end

    def test_bulk_delete_versions
      assert_async_task ::Actions::Katello::ContentView::Remove do |view, options|
        @library_dev_staging_view == view &&
          options[:system_content_view_id] == @library_dev_staging_view.id &&
          options[:system_environment_id] == @library.id &&
          options[:key_content_view_id] == @library_dev_staging_view.id &&
          options[:key_environment_id] == @library.id &&
          @library_dev_staging_view.versions.sort == options[:content_view_versions].sort &&
          view.content_view_environments.sort == options[:content_view_environments].sort
      end

      put :bulk_delete_versions, params: {
        key_content_view_id: @library_dev_staging_view.id,
        key_environment_id: @library.id,
        system_content_view_id: @library_dev_staging_view.id,
        system_environment_id: @library.id,
        bulk_content_view_version_ids: {
          included: {
            ids: @library_dev_staging_view.versions.map(&:id)
          }
        },
        id: @library_dev_staging_view.id
      }

      assert_response :success

      @library_dev_staging_view
    end

    def test_remove_from_environment
      refute_includes @library_dev_view.environments, @staging
      delete :remove_from_environment, params: { id: @library_dev_view.id, environment_id: @staging.id }
      assert_response 400
    end

    def test_remove_from_environment_protected
      dev_env_read_permission = {:name => :view_lifecycle_environments, :search => "id=\"#{@dev.id}\"" }
      dev_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments, :search => "name=\"#{@dev.name}\"" }
      library_dev_staging_view_remove_permission = {:name => :promote_or_remove_content_views, :search => "name=\"#{@library_dev_staging_view.name}\"" }

      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      diff_env = @staging
      diff_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments, :search => "name=\"#{diff_env.name}\"" }
      diff_view_remove_permission = {:name => :promote_or_remove_content_views, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [[:promote_or_remove_content_views_to_environments, :promote_or_remove_content_views, dev_env_read_permission],
                       [dev_env_remove_permission, library_dev_staging_view_remove_permission, dev_env_read_permission],
                       [dev_env_remove_permission, :promote_or_remove_content_views, dev_env_read_permission],
                       [:promote_or_remove_content_views_to_environments, library_dev_staging_view_remove_permission, dev_env_read_permission]
                      ]
      denied_perms = [@view_permission,
                      @create_permission,
                      @update_permission,
                      :destroy_content_views,
                      :promote_or_remove_content_views_to_environments,
                      :promote_or_remove_content_views,
                      [diff_env_remove_permission, :promote_or_remove_content_views],
                      [:promote_or_remove_content_views_to_environments, diff_view_remove_permission]
                     ]

      assert_protected_action(:remove_from_environment, allowed_perms, denied_perms) do
        delete :remove_from_environment, params: { :id => @library_dev_staging_view.id, :environment_id => @dev.id }
      end
    end

    def test_remove_protected
      input_envs_remove_permission = {:name => :promote_or_remove_content_views_to_environments, :search => "name=\"#{@dev.name}\" or name=\"#{@staging.name}\"" }
      single_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments, :search => "name=\"#{@dev.name}\"" }

      library_dev_staging_view_remove_permission = {:name => :promote_or_remove_content_views, :search => "name=\"#{@library_dev_staging_view.name}\"" }

      library_dev_staging_view_destroy_permission = {:name => :destroy_content_views, :search => "name=\"#{@library_dev_staging_view.name}\"" }

      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      diff_env = KTEnvironment.find(katello_environments(:dev_path1).id)

      diff_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments, :search => "name=\"#{diff_env.name}\"" }
      diff_view_remove_permission = {:name => :promote_or_remove_content_views, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [[:promote_or_remove_content_views_to_environments, :promote_or_remove_content_views],
                       [:promote_or_remove_content_views_to_environments, :promote_or_remove_content_views, :destroy_content_views],
                       [input_envs_remove_permission, library_dev_staging_view_remove_permission],
                       [input_envs_remove_permission, library_dev_staging_view_remove_permission, library_dev_staging_view_destroy_permission],
                       [input_envs_remove_permission, :promote_or_remove_content_views],
                       [:promote_or_remove_content_views_to_environments, library_dev_staging_view_remove_permission]
                      ]
      denied_perms = [@view_permission,
                      @create_permission,
                      @update_permission,
                      :destroy_content_views,
                      :promote_or_remove_content_views_to_environments,
                      :promote_or_remove_content_views,
                      [diff_env_remove_permission, :promote_or_remove_content_views],
                      [single_env_remove_permission, :promote_or_remove_content_views],
                      [:promote_or_remove_content_views_to_environments, diff_view_remove_permission]
                     ]

      env_ids = [@dev.id.to_s, @staging.id.to_s]
      Katello::ActivationKey.expects(:where).at_least_once.returns([]).with do |args|
        args[:content_view_id].id == @library_dev_staging_view.id && args[:environment_id] == env_ids
      end

      assert_protected_action(:remove, allowed_perms, denied_perms) do
        put :remove, params: { :id => @library_dev_staging_view.id, :environment_ids => env_ids }
      end
    end

    def test_remove_protected_with_no_environment_ids
      library_dev_staging_view_destroy_permission = {:name => :destroy_content_views, :search => "name=\"#{@library_dev_staging_view.name}\"" }

      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      diff_view_destroy_permission = {:name => :destroy_content_views, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [:destroy_content_views, library_dev_staging_view_destroy_permission]

      denied_perms = [@view_permission,
                      @create_permission,
                      @update_permission,
                      diff_view_destroy_permission,
                      [:promote_or_remove_content_views_to_environments, :promote_or_remove_content_views]
                     ]

      assert_protected_action(:remove, allowed_perms, denied_perms) do
        put :remove, params: { :id => @library_dev_staging_view.id, :content_view_version_ids => [@library_dev_staging_view.version(@dev).id,
                                                                                                  @library_dev_staging_view.version(@staging).id] }
      end
    end

    def test_remove_protected_envs_with_host
      content_view = katello_content_views(:library_dev_view)
      environment = katello_environments(:library)

      host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => content_view,
                                :lifecycle_environment => environment)

      host_edit_permission = {:name => :edit_hosts, :search => "name=\"#{host.name}\"" }

      host_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments,
                                    :search => "name=\"#{environment.name}\"" }

      host_cv_remove_permission = {:name => :promote_or_remove_content_views,
                                   :search => "name=\"#{content_view.name}\"" }

      alternate_env = @staging
      alternate_env_read_permission = {:name => :view_lifecycle_environments,
                                       :search => "name=\"#{alternate_env.name}\"" }

      alternate_cv = @library_dev_staging_view
      alternate_cv_read_permission = {:name => :view_content_views,
                                      :search => "name=\"#{alternate_cv.name}\"" }

      bad_cv = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      bad_cv_read_permission = {:name => :view_content_views,
                                :search => "name=\"#{bad_cv.name}\"" }

      bad_env = KTEnvironment.find(katello_environments(:dev_path1).id)
      bad_env_read_permission = {:name => :view_lifecycle_environments,
                                 :search => "name=\"#{bad_env.name}\"" }

      allowed_perms = [[:edit_hosts, :promote_or_remove_content_views, :view_content_views,
                        :promote_or_remove_content_views_to_environments, :view_lifecycle_environments],
                       [host_edit_permission, host_cv_remove_permission, host_env_remove_permission,
                        alternate_env_read_permission, alternate_cv_read_permission]
                      ]

      denied_perms = [[:edit_hosts, :promote_or_remove_content_views,
                       :promote_or_remove_content_views_to_environments, :view_lifecycle_environments],
                      [host_edit_permission, host_cv_remove_permission, host_env_remove_permission,
                       bad_env_read_permission, alternate_cv_read_permission],
                      [host_edit_permission, host_cv_remove_permission, host_env_remove_permission,
                       alternate_env_read_permission, bad_cv_read_permission]
                     ]

      env_ids = [environment.id.to_s]

      Katello::ActivationKey.expects(:where).at_least_once.returns([]).with do |args|
        args[:content_view_id].id == content_view.id && args[:environment_id] == env_ids
      end

      assert_protected_action(:remove, allowed_perms, denied_perms) do
        User.current.update_attribute(:organizations, [host.organization])
        User.current.update_attribute(:locations, [host.location])
        put :remove, params: { :id => content_view.id, :environment_ids => env_ids, :system_content_view_id => alternate_cv.id, :system_environment_id => alternate_env.id }
      end
    end

    def test_remove_protected_envs_with_activation_keys
      ak = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key).id)
      ak_edit_permission = {:name => :edit_activation_keys, :search => "name=\"#{ak.name}\"" }

      ak_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments,
                                  :search => "name=\"#{ak.environment.name}\"" }

      ak_cv_remove_permission = {:name => :promote_or_remove_content_views,
                                 :search => "name=\"#{ak.content_view.name}\"" }

      alternate_env = @staging
      alternate_env_read_permission = {:name => :view_lifecycle_environments,
                                       :search => "name=\"#{alternate_env.name}\"" }

      alternate_cv = @library_dev_staging_view
      alternate_cv_read_permission = {:name => :view_content_views,
                                      :search => "name=\"#{alternate_cv.name}\"" }

      bad_cv = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      bad_cv_read_permission = {:name => :view_content_views,
                                :search => "name=\"#{bad_cv.name}\"" }

      bad_env = KTEnvironment.find(katello_environments(:dev_path1).id)
      bad_env_read_permission = {:name => :view_lifecycle_environments,
                                 :search => "name=\"#{bad_env.name}\"" }

      allowed_perms = [[:edit_activation_keys, :promote_or_remove_content_views, :view_content_views,
                        :promote_or_remove_content_views_to_environments, :view_lifecycle_environments],
                       [ak_edit_permission, ak_cv_remove_permission, ak_env_remove_permission,
                        alternate_env_read_permission, alternate_cv_read_permission]
                      ]

      denied_perms = [[:edit_activation_keys, :promote_or_remove_content_views,
                       :promote_or_remove_content_views_to_environments, :view_lifecycle_environments],
                      [ak_edit_permission, ak_cv_remove_permission, ak_env_remove_permission,
                       bad_env_read_permission, alternate_cv_read_permission],
                      [ak_edit_permission, ak_cv_remove_permission, ak_env_remove_permission,
                       alternate_env_read_permission, bad_cv_read_permission]
                     ]

      assert_protected_action(:remove, allowed_perms, denied_perms) do
        put :remove, params: { :id => ak.content_view.id, :environment_ids => [ak.environment.id], :key_content_view_id => alternate_cv.id, :key_environment_id => alternate_env.id }
      end
    end
  end
end
