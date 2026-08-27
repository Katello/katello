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

    def test_index_returns_deterministic_order
      # Create additional capsules with content to test ordering
      proxy2 = FactoryBot.create(:smart_proxy, :with_pulp3)
      proxy2.organizations = @organization
      proxy2.locations = @location
      proxy2.save!

      proxy3 = FactoryBot.create(:smart_proxy, :with_pulp3)
      proxy3.organizations = @organization
      proxy3.locations = @location
      proxy3.save!

      # Get all capsules
      get :index
      assert_response :success

      body = JSON.parse(response.body)
      ids = body['results'].map { |r| r['id'] }

      # Verify results are ordered by ID (ascending)
      assert_equal ids.sort, ids, "Capsules should be returned in ascending ID order"

      # Make the same request again to verify consistent ordering
      get :index
      assert_response :success

      body2 = JSON.parse(response.body)
      ids2 = body2['results'].map { |r| r['id'] }

      # Verify same order on repeated requests
      assert_equal ids, ids2, "Repeated requests should return capsules in the same order"
    end
  end
end
