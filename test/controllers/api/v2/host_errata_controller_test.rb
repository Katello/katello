# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostErrataControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    tests ::Katello::Api::V2::HostErrataController

    def permissions
      @view_permission = :view_hosts
      @create_permission = :create_hosts
      @update_permission = :edit_hosts
      @destroy_permission = :destroy_hosts
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      @host = hosts(:one)
      @host_dev = hosts(:two)
      @host_without_content_facet = hosts(:without_content_facet)

      setup_foreman_routes
      permissions
    end

    def test_index
      get :index, :host_id => @host_dev.id

      assert_response :success
      assert_template 'api/v2/host_errata/index'
    end

    def test_index_without_content_facet
      get :index, :host_id => @host_without_content_facet.id

      assert_response :success
      assert_template 'api/v2/host_errata/index'
    end

    def test_index_other_env
      @default_content_view = katello_content_views(:acme_default)
      @library = katello_environments(:library)
      get :index, :host_id => @host_dev.id, :content_view_id => @default_content_view.id,
          :environment_id => @library.id

      assert_response :success
      assert_template 'api/v2/host_errata/index'
    end

    def test_apply
      assert_async_task ::Actions::Katello::Host::Erratum::Install do |host, errata|
        host.id == @host.id && errata == %w(RHSA-1999-1231)
      end

      put :apply, :host_id => @host.id, :errata_ids => %w(RHSA-1999-1231)

      assert_response :success
    end

    def test_apply_unknown_errata
      put :apply, :host_id => @host.id, :errata_ids => %w(non-existant-errata)
      assert_response 404
    end

    def test_apply_protected
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:apply, good_perms, bad_perms) do
        put :apply, :host_id => @host.id, :errata_ids => %w(RHSA-1999-1231)
      end
    end
  end
end
