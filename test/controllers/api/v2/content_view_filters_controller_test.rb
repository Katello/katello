# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ContentViewFiltersControllerTest < ActionController::TestCase
    def models
      @content_view = katello_content_views(:library_view)
      @filter = katello_content_view_filters(:simple_filter)
      @package_group_filter = katello_content_view_filters(:populated_package_group_filter)
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
      [:package_group_count, :package_count].each do |content_type_count|
        Repository.any_instance.stubs(content_type_count).returns(0)
      end
    end

    def test_index
      get :index

      assert_response :success
      assert_template 'api/v2/content_view_filters/index'
    end

    def test_index_with_content_view
      get :index, params: { :content_view_id => @content_view.id }

      body = JSON.parse(response.body)
      filter_count = ContentViewFilter.where(:content_view_id => @content_view.id).count
      returned_filter_count = body["total"]

      assert_equal returned_filter_count, filter_count
      assert_response :success
      assert_template 'api/v2/content_view_filters/index'
    end

    def test_index_with_search
      get :index, params: { :search => "name = #{@filter.name}" }

      assert_response :success
      assert_template 'api/v2/content_view_filters/index'
    end

    def test_index_with_name
      response = get :index, params: { :name => @filter.name }
      results = JSON.parse(response.body)
      assert_equal @filter.id, results['results'][0]['id']
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@content_view.organization]) do
        get :index, params: { :content_view_id => @content_view.id }
      end
    end

    def test_create
      @content_view = katello_content_views(:library_dev_view)
      assert_empty @content_view.filters

      post :create, params: { :content_view_id => @content_view.id, :name => "My Filter", :type => "rpm" }

      assert_response :success
      assert_template :layout => 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/create'
      assert_includes @content_view.reload.filters.map(&:name), "My Filter"
    end

    def test_create_with_original_module_streams
      @content_view = katello_content_views(:library_dev_view)
      assert_empty @content_view.filters

      post :create, params: { :content_view_id => @content_view.id, :name => "My Filter", :type => "modulemd", :original_module_streams => true }

      assert_response :success
      assert_template :layout => 'katello/api/v2/layouts/resource'
      assert_template 'katello/api/v2/common/create'
      assert @content_view.reload.filters.first.original_module_streams
    end

    def test_create_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms, [@content_view.organization]) do
        post :create, params: { :name => "Test", :content_view_id => @content_view.id }
      end
    end

    def test_show
      get :show, params: { :content_view_id => @filter.content_view_id, :id => @filter.id }

      assert_response :success
      assert_template 'api/v2/content_view_filters/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms, [@filter.content_view.organization]) do
        get :show, params: { :content_view_id => @filter.content_view_id, :id => @filter.id }
      end
    end

    def test_update_name
      put :update, params: { :content_view_id => @filter.content_view_id, :id => @filter, :name => "New Filter Name" }
      assert_response :success
      assert_template 'api/v2/common/update'
      assert_equal @filter.reload.name, "New Filter Name"
    end

    def test_update_description
      put :update, params: { :content_view_id => @filter.content_view_id, :id => @filter, :description => "New Description" }
      assert_response :success
      assert_template 'api/v2/common/update'
      assert_equal @filter.reload.description, "New Description"
    end

    def test_update_repositories
      repository = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      assert_includes @content_view.repositories.map(&:id), repository.id
      refute_includes @filter.repositories.reload.map(&:id), repository.id

      put :update, params: { :content_view_id => @filter.content_view_id, :id => @filter, :repository_ids => [repository.id] }

      assert_response :success
      assert_includes @filter.repositories.reload.map(&:id), repository.id
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission,
                      {:name => "read_content_views", :search => "name=\"#{@filter.content_view.name}\"" }]

      assert_protected_action(:update, allowed_perms, denied_perms, [@filter.content_view.organization]) do
        put :update, params: { :content_view_id => @filter.content_view_id, :id => @filter.id, :name => "new name" }
      end
    end

    def test_update_protected_object
      allowed_perms = [{:name => "edit_content_views", :search => "name=\"#{@filter.content_view.name}\"" }]
      denied_perms = [{:name => "edit_content_views", :search => "name=\"some_name\"" }]

      assert_protected_object(:update, allowed_perms, denied_perms, [@filter.content_view.organization]) do
        put :update, params: { :content_view_id => @filter.content_view_id, :id => @filter.id, :name => "new name" }
      end
    end

    def test_update_with_original_module_streams
      @filter = katello_content_view_filters(:populated_module_stream_filter)
      refute @filter.original_module_streams
      put :update, params: { :content_view_id => @filter.content_view_id, :id => @filter, :original_module_streams => true }
      assert_response :success
      assert_template 'api/v2/common/update'
      assert @filter.reload.original_module_streams
    end

    def test_add_rules_bulk
      mammals_pg = katello_package_groups(:mammals_pg)
      put :add_filter_rules, params: { :id => @package_group_filter, :rules_params => [{uuid: mammals_pg.pulp_id}]}
      assert_response :success
    end

    def test_remove_rules_bulk
      rules = @package_group_filter.package_group_rules.pluck(:id)
      put :remove_filter_rules, params: { :id => @package_group_filter, :rule_ids => rules}
      assert_response :success
      assert_equal @package_group_filter.package_group_rules, []
    end

    def test_destroy
      delete :destroy, params: { :content_view_id => @filter.content_view_id, :id => @filter.id }

      results = JSON.parse(response.body)
      refute results.blank?
      assert_equal results['id'], @filter.id

      assert_response :success
      assert_nil ContentViewFilter.find_by_id(@filter.id)
    end

    def test_destroy_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@filter.content_view.organization]) do
        delete :destroy, params: { :content_view_id => @filter.content_view_id, :id => @filter.id }
      end
    end
  end
end
