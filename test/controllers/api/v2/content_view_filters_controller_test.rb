# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ContentViewFiltersControllerTest < ActionController::TestCase
    def models
      @content_view = katello_content_views(:library_view)
      @filter = katello_content_view_filters(:simple_filter)
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
    end

    def setup
      setup_controller_defaults_api
      Repository.any_instance.stubs(:last_sync).returns(Time.now.asctime)
      ::Katello::Erratum.any_instance.stubs(:repositories).returns([])
      models
      permissions
      [:package_group_count, :package_count, :puppet_module_count].each do |content_type_count|
        Repository.any_instance.stubs(content_type_count).returns(0)
      end
    end

    def test_index
      get :index

      assert_response :success
      assert_template 'api/v2/content_view_filters/index'
    end

    def test_index_with_content_view
      get :index, :content_view_id => @content_view.id

      body = JSON.parse(response.body)
      filter_count = ContentViewFilter.where(:content_view_id => @content_view.id).count
      returned_filter_count = body["total"]

      assert_equal returned_filter_count, filter_count
      assert_response :success
      assert_template 'api/v2/content_view_filters/index'
    end

    def test_index_with_search
      get :index, :search => "name = #{@filter.name}"

      assert_response :success
      assert_template 'api/v2/content_view_filters/index'
    end

    def test_index_with_name
      response = get :index, :name => @filter.name
      results = JSON.parse(response.body)
      assert_equal @filter.id, results['results'][0]['id']
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_id => @content_view.id
      end
    end

    def test_create
      @content_view = katello_content_views(:library_dev_view)
      assert_empty @content_view.filters

      post :create, :content_view_id => @content_view.id, :name => "My Filter", :type => "rpm"

      assert_response :success
      assert_template %w(katello/api/v2/content_view_filters/show)
      assert_includes @content_view.reload.filters.map(&:name), "My Filter"
    end

    def test_create_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :name => "Test", :content_view_id => @content_view.id
      end
    end

    def test_show
      get :show, :content_view_id => @filter.content_view_id, :id => @filter.id

      assert_response :success
      assert_template 'api/v2/content_view_filters/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :content_view_id => @filter.content_view_id, :id => @filter.id
      end
    end

    def test_update_name
      put :update, :content_view_id => @filter.content_view_id, :id => @filter, :name => "New Filter Name"
      assert_response :success
      assert_template 'api/v2/common/update'
      assert_equal @filter.reload.name, "New Filter Name"
    end

    def test_update_repositories
      repository = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      assert_includes @content_view.repositories.map(&:id), repository.id
      refute_includes @filter.repositories(true).map(&:id), repository.id

      put :update, :content_view_id => @filter.content_view_id, :id => @filter,
          :repository_ids => [repository.id]

      assert_response :success
      assert_includes @filter.repositories(true).map(&:id), repository.id
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :content_view_id => @filter.content_view_id, :id => @filter.id, :name => "new name"
      end
    end

    def test_destroy
      delete :destroy, :content_view_id => @filter.content_view_id, :id => @filter.id

      results = JSON.parse(response.body)
      refute results.blank?
      assert_equal results['id'], @filter.id

      assert_response :success
      assert_nil ContentViewFilter.find_by_id(@filter.id)
    end

    def test_destroy_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :content_view_id => @filter.content_view_id, :id => @filter.id
      end
    end
  end
end
