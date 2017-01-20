# encoding: utf-8

require "katello_test_helper"

# rubocop:disable Metrics/MethodLength
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
      ContentViewVersion.any_instance.stubs(:puppet_module_count).returns(0)

      models
      permissions
      [:package_group_count, :package_count, :puppet_module_count].each do |content_type_count|
        Repository.any_instance.stubs(content_type_count).returns(0)
      end
    end

    def test_index
      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/content_views/index'
    end

    def test_index_in_environment
      get :index, :organization_id => @organization.id, :environment_id => @dev.id

      assert_response :success
      assert_template 'api/v2/content_views/index'
    end

    def test_index_with_composite_filter
      get :index, :organization_id => @organization.id, :composite => true

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

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.id
      end
    end

    def test_create
      post :create, :name => "My View", :label => "My_View", :description => "Cool",
        :organization_id => @organization.id

      assert_response :success
      assert_template :layout => 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/create'
    end

    def test_create_fail_without_organization_id
      post :create, :name => "My View", :label => "My_View", :description => "Cool"

      assert_response :not_found
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :name => "Test", :organization_id => @organization.id
      end
    end

    def test_create_with_non_json_request
      @request.env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
      post :create, :name => "My View", :description => "Cool",
        :organization_id => @organization.id

      assert_response 415
    end

    def test_show
      get :show, :id => @library_dev_staging_view.id

      assert_response :success
      assert_template 'api/v2/content_views/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :id => @library_dev_staging_view.id
      end
    end

    def test_update
      params = { :name => "My View" }
      assert_sync_task(::Actions::Katello::ContentView::Update) do |_content_view, content_view_params|
        content_view_params.key?(:name).must_equal true
        content_view_params[:name].must_equal params[:name]
      end
      put :update, :id => @library_dev_staging_view.id, :content_view => params

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_repositories
      repository = katello_repositories(:fedora_17_unpublished)

      params = { :repository_ids => [repository.id.to_s] }
      assert_sync_task(::Actions::Katello::ContentView::Update) do |_content_view, content_view_params|
        content_view_params.key?(:repository_ids).must_equal true
        content_view_params[:repository_ids].must_equal params[:repository_ids]
      end
      put :update, :id => @library_dev_staging_view.id, :content_view => params

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_components
      version = @library_dev_staging_view.versions.first
      composite = ContentView.find(katello_content_views(:composite_view).id)

      params = { :component_ids => [version.id.to_s] }
      assert_sync_task(::Actions::Katello::ContentView::Update) do |_content_view, content_view_params|
        content_view_params.key?(:component_ids).must_equal true
        content_view_params[:component_ids].must_equal params[:component_ids]
      end
      put :update, :id => composite.id, :content_view => params

      assert_response :success
      assert_template layout: 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/update'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, :destroy_content_views]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :id => @library_dev_staging_view.id, :name => "new name"
      end
    end

    def test_available_puppet_modules
      get :available_puppet_modules, :id => @library_dev_staging_view.id

      assert_response :success
      assert_template 'katello/api/v2/content_views/puppet_modules'
    end

    def test_available_puppet_modules_filtered_order
      # the UI relies on these being ordered by author/name/version
      create(:puppet_module, :version => "1.12.0")
      create(:puppet_module, :version => "1.3.0")
      PuppetModule.stubs(:in_repositories).returns(PuppetModule.all)

      get :available_puppet_modules, :id => @library_dev_staging_view.id, :name => "trystero"

      results = JSON.parse(response.body)['results']
      assert_equal '1.12.0', results.first['version']
    end

    def test_available_puppet_modules_with_use_latest
      create(:puppet_module, :version => "1.2.0")
      create(:puppet_module, :version => "1.3.0")
      PuppetModule.stubs(:in_repositories).returns(PuppetModule.all)

      get :available_puppet_modules, :id => @library_dev_staging_view.id, :name => "trystero"
      results = JSON.parse(response.body)['results']

      assert_equal '1.3.0', results.first['version']
      use_latest_rec = results.last
      assert_equal 'Always Use Latest (currently 1.3.0)', use_latest_rec['version']
      assert_equal nil, use_latest_rec['uuid']
    end

    def test_available_puppet_modules_when_latest_module_already_selected
      content_view = katello_content_views(:library_view)
      create(:puppet_module, :name => 'm1', :author => 'kavy', :version => "1.2.0")
      puppet_module2 = create(:puppet_module, :name => 'm1', :author => 'kavy', :version => "1.3.0")
      cv_puppet_module = ContentViewPuppetModule.find(katello_content_view_puppet_modules(:library_view_m1_module).id)
      cv_puppet_module.uuid = puppet_module2.uuid
      cv_puppet_module.save
      PuppetModule.stubs(:in_repositories).returns(PuppetModule.all)
      get :available_puppet_modules, :id => content_view.id, :name => 'm1'
      results = JSON.parse(response.body)['results']
      assert_equal '1.2.0', results.first['version']
      assert_equal 2, results.count
      assert_match(/\(currently 1\.3\.0\)/, results.last['version'])
    end

    def test_available_puppet_modules_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:available_puppet_modules, allowed_perms, denied_perms) do
        get :available_puppet_modules, :id => @library_dev_staging_view.id
      end
    end

    def test_available_puppet_module_names
      get :available_puppet_module_names, :id => @library_dev_staging_view.id

      assert_response :success
      assert_template 'katello/api/v2/content_views/../puppet_modules/names'
    end

    def test_available_puppet_module_names_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:available_puppet_module_names, allowed_perms, denied_perms) do
        get :available_puppet_module_names, :id => @library_dev_staging_view.id
      end
    end

    def test_publish_default_view
      view = ContentView.find(katello_content_views(:acme_default).id)
      version_count = view.versions.count
      post :publish, :id => view.id
      assert_response 400
      assert_equal version_count, view.versions.reload.count
    end

    def test_destroy
      view = ContentView.create!(:name => "Cat",
                                 :organization => @organization
                                )
      delete :destroy, :id => view.id
      assert_response :success
    end

    def test_destroy_protected
      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      diff_view_destroy_permission = {:name => :destroy_content_views, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [:destroy_content_views]
      denied_perms = [@view_permission, @create_permission, @update_permission, diff_view_destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :id => @library_dev_staging_view.id
      end
    end

    def test_copy
      post :copy, :id => @library_dev_staging_view.id, :name => "My New View"

      assert_response :success
      assert_template "katello/api/v2/content_views/copy"
    end

    def test_copy_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :copy, :id => @library_dev_staging_view.id, :name => "Test"
      end
    end

    def test_remove_from_environment
      refute @library_dev_view.environments.include?(@staging)
      delete :remove_from_environment, id: @library_dev_view.id, environment_id: @staging.id
      assert_response 400
    end

    def test_remove_from_environment_protected
      dev_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments, :search => "name=\"#{@dev.name}\"" }
      library_dev_staging_view_remove_permission = {:name => :promote_or_remove_content_views, :search => "name=\"#{@library_dev_staging_view.name}\"" }

      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv).id)
      diff_env = @staging
      diff_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments, :search => "name=\"#{diff_env.name}\"" }
      diff_view_remove_permission = {:name => :promote_or_remove_content_views, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [[:promote_or_remove_content_views_to_environments, :promote_or_remove_content_views],
                       [dev_env_remove_permission, library_dev_staging_view_remove_permission],
                       [dev_env_remove_permission, :promote_or_remove_content_views],
                       [:promote_or_remove_content_views_to_environments, library_dev_staging_view_remove_permission]
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
        delete :remove_from_environment, :id => @library_dev_staging_view.id, :environment_id => @dev.id
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
      ::Katello::Host::ContentFacet.expects(:where).at_least_once.returns([]).with do |args|
        args[:content_view_id].id == @library_dev_staging_view.id && args[:lifecycle_environment_id] == env_ids
      end

      Katello::ActivationKey.expects(:where).at_least_once.returns([]).with do |args|
        args[:content_view_id].id == @library_dev_staging_view.id && args[:environment_id] == env_ids
      end

      assert_protected_action(:remove, allowed_perms, denied_perms) do
        put :remove, :id => @library_dev_staging_view.id, :environment_ids => env_ids
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
        put :remove, :id => @library_dev_staging_view.id,
                     :content_view_version_ids => [@library_dev_staging_view.version(@dev).id,
                                                   @library_dev_staging_view.version(@staging).id]
      end
    end

    def test_remove_protected_envs_with_host
      content_view = katello_content_views(:library_dev_view)
      environment = katello_environments(:library)

      host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => content_view,
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
        put :remove, :id => content_view.id,
                     :environment_ids => env_ids,
                     :system_content_view_id => alternate_cv.id,
                     :system_environment_id => alternate_env.id
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

      env_ids = [ak.environment.id.to_s]

      ::Katello::Host::ContentFacet.expects(:where).at_least_once.returns([]).with do |args|
        args[:content_view_id].id == ak.content_view.id && args[:lifecycle_environment_id] == env_ids
      end

      assert_protected_action(:remove, allowed_perms, denied_perms) do
        put :remove, :id => ak.content_view.id,
                     :environment_ids => [ak.environment.id],
                     :key_content_view_id => alternate_cv.id,
                     :key_environment_id => alternate_env.id
      end
    end
  end
end
