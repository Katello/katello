# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostAutocompleteControllerTest < ActionController::TestCase
    tests ::Katello::Api::V2::HostAutocompleteController

    def permissions
      @view_permission = :view_hosts
      @create_permission = :create_hosts
      @update_permission = :edit_hosts
      @destroy_permission = :destroy_hosts
    end

    def setup
      setup_controller_defaults_api
      login_user(users(:admin))

      @host = hosts(:one)

      setup_foreman_routes
      permissions
    end

    def test_install_package
      get :auto_complete_search, :search => "name "

      assert_response :success
    end

    def test_permissions
      good_perms = [@view_permission]
      bad_perms = [@update_permission, @create_permission, @destroy_permission]

      assert_protected_action(:auto_complete_search, good_perms, bad_perms) do
        get :auto_complete_search, :search => "name "
      end
    end
  end
end
