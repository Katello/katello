# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::CapsulesControllerTest < ActionController::TestCase
    include Support::CapsuleSupport
    include Support::ForemanTasks::Task

    def setup
      setup_controller_defaults_api
      @repository = katello_repositories(:fedora_17_unpublished)
      @library_dev_view = ContentView.find(katello_content_views(:library_dev_view).id)
      @location = Location.all
      @organization = [get_organization]

      proxy_with_pulp.organizations = @organization
      proxy_with_pulp.locations = @location
    end

    def view_smart_proxies_perms
      [[:view_smart_proxies]]
    end

    def incorrect_perms
      [[:view_capsule_content, :manage_capsule_content]]
    end

    def environment
      @environment ||= katello_environments(:library)
    end

    def test_admin_index
      get :index
      assert_response :success
    end

    def test_index_only_includes_pulp_smart_proxies
      non_pulp_proxy = FactoryBot.create(:smart_proxy)
      non_pulp_proxy.organizations = @organization
      non_pulp_proxy.locations = @location
      refute non_pulp_proxy.pulp3_enabled?

      get :index, params: { per_page: 'all' }

      assert_response :success
      proxy_ids = JSON.parse(response.body)['results'].map { |proxy| proxy['id'] }
      assert_includes proxy_ids, proxy_with_pulp.id
      refute_includes proxy_ids, non_pulp_proxy.id
    end

    def test_admin_show
      get :show, params: { :id => proxy_with_pulp.id}
      assert_response :success
    end

    def test_user_index
      assert_protected_action(:index, view_smart_proxies_perms, incorrect_perms, @organization) do
        get :index
      end
    end

    def test_user_show
      assert_protected_action(:show, view_smart_proxies_perms, incorrect_perms,
                              @organization, @location) do
        get :show, params: { :id => proxy_with_pulp.id}
      end
    end
  end
end
