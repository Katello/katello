# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ContentViewComponentsControllerTest < ActionController::TestCase
    def models
      @composite = create(:katello_content_view, :composite)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @destroy_permission = :destroy_content_views
      @update_permission = :edit_content_views
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      models
      permissions
    end

    def create_component
      @content_view = katello_content_views(:library_dev_view)
      ContentViewComponent.create!(:composite_content_view => @composite,
                                   :content_view => @content_view, :latest => true)
    end

    def test_index
      get :index, params: { :composite_content_view_id => @composite.id }

      assert_response :success
      assert_template 'api/v2/content_view_components/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@composite.organization]) do
        get :index, params: { :composite_content_view_id => @composite.id }
      end
    end

    def test_add_components_with_content_view
      @content_view = katello_content_views(:library_dev_view)
      @content_view_version = katello_content_view_versions(:library_dev_view_version)
      put :add_components, params: { :composite_content_view_id => @composite.id, :components => [{:content_view_id => @content_view.id, :latest => true}] }

      assert_response :success

      assert_template :layout => 'katello/api/v2/layouts/collection'
      assert_template "katello/api/v2/content_view_components/index"

      assert_equal @content_view, @composite.reload.content_view_components.first.content_view
      assert_equal @content_view_version, @composite.reload.components.first
    end

    def test_add_components_with_content_view_version
      @content_view_version = katello_content_view_versions(:library_dev_view_version)
      put :add_components, params: { :composite_content_view_id => @composite.id, :components => [{:content_view_version_id => @content_view_version.id, :latest => false}] }
      assert_response :success
      assert_template :layout => 'katello/api/v2/layouts/collection'
      assert_template "katello/api/v2/content_view_components/index"

      assert_equal @content_view_version, @composite.reload.components.first
    end

    def test_add_components_protected
      @content_view = katello_content_views(:library_dev_view)

      allowed_perms = [[@update_permission, {:name => "view_content_views", :search => "name=\"#{@content_view.name}\"" }]]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms, [@content_view.organization]) do
        put :add_components, params: { :composite_content_view_id => @composite.id, :components => [{:content_view_id => @content_view.id, :latest => true}] }
      end
    end

    def test_add_components_protected_object
      @content_view = katello_content_views(:library_dev_view)

      allowed_perms = [[@update_permission, {:name => "view_content_views", :search => "name=\"#{@content_view.name}\"" }]]
      denied_perms = [[@update_permission, {:name => "view_content_views", :search => "name=\"someothername\"" }]]

      assert_protected_object(:create, allowed_perms, denied_perms, [@composite.organization]) do
        put :add_components, params: { :composite_content_view_id => @composite.id, :components => [{:content_view_id => @content_view.id, :latest => true}] }
      end
    end

    def test_show_all
      get :show_all, params: { :composite_content_view_id => @composite.id }

      assert_response :success
      assert_template 'api/v2/content_view_components/index'
    end

    def test_show
      component = create_component
      get :show, params: { :composite_content_view_id => @composite.id, :id => component.id }
      assert_response :success
      assert_template 'api/v2/content_view_components/show'
    end

    def test_show_protected
      component = create_component
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms, [@composite.organization]) do
        get :show, params: { :composite_content_view_id => @composite.id, :id => component.id }
      end
    end

    def test_update_latest_false
      component = create_component
      assert component.latest?
      assert_nil component.content_view_version

      computed_version = component.latest_version.id
      put :update, params: { :composite_content_view_id => @composite.id, :id => component.id, :content_view_version_id => computed_version, :latest => false }

      assert_response :success
      assert_template 'api/v2/common/update'
      component = component.reload
      assert_equal computed_version, component.content_view_version_id
      refute component.latest?
    end

    def test_update_latest_true
      component = create_component
      computed_version = component.latest_version.id
      component.update!(:latest => true, :content_view_version_id => nil)
      put :update, params: { :composite_content_view_id => @composite.id, :id => component.id, :latest => true }
      assert_response :success
      assert_template 'api/v2/common/update'
      component = component.reload
      assert_nil component.content_view_version
      assert component.latest?
      assert computed_version, component.latest_version.id
    end

    def test_update_latest_conflict
      component = create_component
      computed_version = component.latest_version.id

      put :update, params: { :composite_content_view_id => @composite.id, :id => component.id, :content_view_version_id => computed_version, :latest => true }
      assert_response 422
    end

    def test_update_protected
      component = create_component
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms, [@composite.organization]) do
        put :update, params: { :composite_content_view_id => @composite.id, :id => component.id, :content_view_version_id => component.latest_version.id, :latest => false }
      end
    end

    def test_update_protected_object
      component = create_component

      allowed_perms = [{:name => "edit_content_views", :search => "name=\"#{@composite.name}\"" }]
      denied_perms = [{:name => "edit_content_views", :search => "name=\"some_name\"" }]

      assert_protected_object(:update, allowed_perms, denied_perms, [@composite.organization]) do
        put :update, params: { :composite_content_view_id => @composite.id, :id => component.id, :content_view_version_id => component.latest_version.id, :latest => false }
      end
    end

    def test_remove_components
      component = create_component
      put :remove_components, params: { :composite_content_view_id => @composite.id, :component_ids => [component.id] }

      assert_response :success
      assert_nil ContentViewComponent.find_by_id(component.id)
    end

    def test_remove_components_protected
      component = create_component
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@composite.organization]) do
        put :remove_components, params: { :composite_content_view_id => @composite.id, :component_ids => [component.id] }
      end
    end
  end
end
