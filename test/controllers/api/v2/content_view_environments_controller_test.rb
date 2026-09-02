require "katello_test_helper"
module Katello
  class Api::V2::ContentViewEnvironmentsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @library_dev_staging_view = katello_content_views(:library_dev_staging_view)
      @staging = KTEnvironment.find(katello_environments(:staging).id)
      @library_dev_staging_ak = katello_activation_keys(:library_dev_staging_view_key)
    end

    def permissions
      @view_cv_permission = :view_content_views
      @view_lce_permission = :view_lifecycle_environments
      @denied_perms = [:create_content_views]
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def resp
      @resp ||= JSON.parse(response.body, object_class: OpenStruct)
    end

    def test_index
      get :index, params: { }

      assert_response :success
      assert resp.total > 0
      assert_template 'api/v2/content_view_environments/index'
    end

    def test_index_org
      get :index, params: { :organization_id => @organization.id }

      assert_response :success
      assert resp.total > 0
      assert(resp.results.all? { |result| result.organization.id == @organization.id })
      assert_template 'api/v2/content_view_environments/index'
    end

    def test_index_in_environment
      get :index, params: { :lifecycle_environment_id => @staging.id }

      assert_response :success
      assert resp.total > 0
      assert(resp.results.all? { |result| result.lifecycle_environment.id == @staging.id })
      assert_template 'api/v2/content_view_environments/index'
    end

    def test_index_in_content_view
      get :index, params: { :content_view_id => @library_dev_staging_view.id }

      assert_response :success
      assert resp.total > 0
      assert(resp.results.all? { |result| result.content_view.id == @library_dev_staging_view.id })
      assert_template 'api/v2/content_view_environments/index'
    end

    def test_index_for_activation_key
      get :index, params: { :activation_key_id => @library_dev_staging_ak.id }

      assert_response :success
      assert resp.total > 0
      assert(resp.results.all? { |result| result.activation_keys.map(&:id).include? @library_dev_staging_ak.id })
      assert_template 'api/v2/content_view_environments/index'
    end

    def test_index_for_hostgroup
      hostgroup = FactoryBot.create(:hostgroup)
      cvenv = katello_content_view_environments(:library_dev_view_library)
      hostgroup.organizations = [cvenv.organization]
      hostgroup.save!
      Katello::Hostgroup::ContentFacet.create!(
        :hostgroup => hostgroup,
        :content_view_environment => cvenv
      )

      get :index, params: { :hostgroup_id => hostgroup.id }

      assert_response :success
      assert resp.total > 0
      assert(resp.results.all? { |result| result.id == cvenv.id })
      assert_template 'api/v2/content_view_environments/index'
    end

    def test_index_protected
      allowed_perms = [@view_cv_permission, @view_lce_permission]
      assert_protected_action(:index, allowed_perms, @denied_perms, [@organization]) do
        get :index, params: {}
      end
    end

    def test_show
      cvenv = katello_content_view_environments(:library_dev_view_library)
      get :show, params: { :id => cvenv.id }

      assert_response :success
      assert_equal cvenv.id, resp.id
      assert_equal cvenv.label, resp.label
      assert_equal cvenv.hostgroups.pluck(:id).sort, resp.hostgroups.map(&:id).sort
      assert_equal cvenv.hostgroups.pluck(:name).sort, resp.hostgroups.map(&:name).sort
      assert_equal cvenv.hostgroups.count, resp.hostgroups_count
      assert_template 'api/v2/content_view_environments/show'
    end

    def test_show_protected
      cvenv = katello_content_view_environments(:library_dev_view_library)
      # ContentViewEnvironment.readable requires both CV and LCE view permissions
      allowed_perms = [[@view_cv_permission, @view_lce_permission]]
      assert_protected_action(:show, allowed_perms, @denied_perms, [@organization]) do
        get :show, params: { :id => cvenv.id }
      end
    end
  end
end
