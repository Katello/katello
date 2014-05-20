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
  class Api::V2::ContentViewsControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["ContentViewEnvironment", "ContentViewVersion",
                "Repository", "ContentViewComponent", "ContentView"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def models
      @organization = get_organization
      @library = KTEnvironment.find(katello_environments(:library))
      @dev = KTEnvironment.find(katello_environments(:dev))
      @staging = KTEnvironment.find(katello_environments(:staging))
      @library_dev_staging_view = ContentView.find(katello_content_views(:library_dev_staging_view))
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :update_content_views
      @publish_permission = :publish_content_views
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      ContentView.any_instance.stubs(:reindex_on_association_change).returns(true)
      ContentViewVersion.any_instance.stubs(:package_count).returns(0)
      ContentViewVersion.any_instance.stubs(:errata_count).returns(0)

      models
      permissions
    end

    def test_index
      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/content_views/index'
    end

    def test_index_fail_without_organization_id
      get :index

      assert_response :not_found
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
      assert_template %w(katello/api/v2/content_views/show)
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
      put :update, :id => @library_dev_staging_view, :name => "My View"

      assert_equal "My View", @library_dev_staging_view.reload.name
      assert_response :success
      assert_template 'api/v2/common/update'
    end

    def test_history
      get :history, :id => @library_dev_staging_view

      assert_response :success
      assert_template 'katello/api/v2/content_views/../content_view_histories/index'
    end

    def test_history_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:history, allowed_perms, denied_perms) do
        get :history, :id => @library_dev_staging_view.id
      end
    end

    def test_update_puppet_repositories
      repository = katello_repositories(:p_forge)
      refute_includes @library_dev_staging_view.repositories(true).map(&:id), repository.id
      put :update, :id => @library_dev_staging_view.id, :repository_ids => [repository.id]
      assert_response 422 # cannot add puppet repos to cv
    end

    def test_update_repositories
      repository = katello_repositories(:fedora_17_unpublished)
      refute_includes @library_dev_staging_view.repositories(true).map(&:id), repository.id
      put :update, :id => @library_dev_staging_view.id, :repository_ids => [repository.id]
      assert_response :success
      assert_includes @library_dev_staging_view.repositories(true).map(&:id), repository.id
    end

    def test_update_components
      ContentViewVersion.any_instance.stubs(:puppet_modules).returns([])
      version = @library_dev_staging_view.versions.first
      composite = ContentView.find(katello_content_views(:composite_view))
      refute_includes composite.components(true).map(&:id), version.id
      put :update, :id => composite.id, :component_ids => [version.id]

      assert_response :success
      assert_includes composite.components(true).map(&:id), version.id
      assert_equal 1, composite.components(true).length
    end

    def test_update_default_view
      view = ContentView.find(katello_content_views(:acme_default))
      name = view.name
      put :update, :id => view.id, :name => "Luke I am your father"
      assert_response 400
      assert_equal name, view.reload.name
    end

    def test_remove_components
      version = @library_dev_staging_view.versions.first
      composite = ContentView.find(katello_content_views(:composite_view))
      composite.components = [version]
      refute_empty composite.components(true)
      put :update, :id => composite.id, :component_ids => []
      assert_empty composite.components(true)
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

    def test_available_puppet_modules_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:available_puppet_modules, allowed_perms, denied_perms) do
        get :available_puppet_modules, :id => @library_dev_staging_view.id
      end
    end

    def test_available_puppet_module_names
      Support::SearchService::FakeSearchService.any_instance.stubs(:facets).returns({'facet_search' => {'terms' => []}})

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
      view = ContentView.find(katello_content_views(:acme_default))
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
      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv))
      diff_view_destroy_permission = {:name => :destroy_content_views, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [:destroy_content_views]
      denied_perms = [@view_permission, @create_permission, @update_permission, diff_view_destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :id => @library_dev_staging_view.id
      end
    end

    def test_remove_from_environment_protected
      dev_env_remove_permission = {:name => :promote_or_remove_content_views_to_environments, :search => "name=\"#{@dev.name}\"" }
      library_dev_staging_view_remove_permission = {:name => :promote_or_remove_content_views, :search => "name=\"#{@library_dev_staging_view.name}\"" }

      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv))
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
                      [:promote_or_remove_content_views_to_environments, diff_view_remove_permission],
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

      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv))
      diff_env = KTEnvironment.find(katello_environments(:dev_path1))

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
                      [:promote_or_remove_content_views_to_environments, diff_view_remove_permission],
                     ]
      assert_protected_action(:remove, allowed_perms, denied_perms) do
        put :remove, :id => @library_dev_staging_view.id, :environment_ids => [@dev.id, @staging.id]
      end
    end

    def test_remove_protected_with_no_environment_ids
      library_dev_staging_view_destroy_permission = {:name => :destroy_content_views, :search => "name=\"#{@library_dev_staging_view.name}\"" }

      diff_view = ContentView.find(katello_content_views(:candlepin_default_cv))
      diff_view_destroy_permission = {:name => :destroy_content_views, :search => "name=\"#{diff_view.name}\"" }

      allowed_perms = [:destroy_content_views, library_dev_staging_view_destroy_permission]

      denied_perms = [@view_permission,
                      @create_permission,
                      @update_permission,
                      diff_view_destroy_permission,
                      [:promote_or_remove_content_views_to_environments, :promote_or_remove_content_views]
                     ]
      assert_protected_action(:remove, allowed_perms, denied_perms) do
        put :remove, :id => @library_dev_staging_view.id
      end
    end
  end
end
