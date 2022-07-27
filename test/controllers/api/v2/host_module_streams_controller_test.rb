# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostModuleStreamsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    tests ::Katello::Api::V2::HostModuleStreamsController

    def permissions
      @view_permission = :view_hosts
      @create_permission = :create_hosts
      @update_permission = :edit_hosts
      @destroy_permission = :destroy_hosts
    end

    def setup
      setup_controller_defaults_api
      login_user(users(:admin))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      @host = hosts(:one)
      @content_facet = katello_content_facets(:content_facet_one)
      @host.content_facet = @content_facet

      setup_foreman_routes
      permissions
    end

    def test_index
      get :index, params: { :host_id => @host.id }

      assert_response :success
    end

    def test_duplicate_streams
      @host.host_available_module_streams.destroy_all
      stream1 = katello_available_module_streams(:available_module_stream_three)
      stream2 = Katello::AvailableModuleStream.create(name: stream1.name, stream: stream1.stream, context: 'foo')
      @host.host_available_module_streams.create(available_module_stream: stream1)
      @host.host_available_module_streams.create(available_module_stream: stream2)

      get :index, params: { :host_id => @host.id }

      body = JSON.parse(response.body)

      assert_equal 1, body['results'].length
    end

    def test_view_permissions
      ::Host.any_instance.stubs(:check_host_registration).returns(true)

      good_perms = [@view_permission]
      bad_perms = [@update_permission, @create_permission, @destroy_permission]

      assert_protected_action(:index, good_perms, bad_perms) do
        user = User.current
        as_admin do
          user.update_attribute(:organizations, [taxonomies(:organization1)])
          @host.update_attribute(:organization, taxonomies(:organization1))
          user.update_attribute(:locations, [taxonomies(:location1)])
          @host.update_attribute(:location, taxonomies(:location1))
        end

        get :index, params: { :host_id => @host.id }
      end
    end
  end
end
