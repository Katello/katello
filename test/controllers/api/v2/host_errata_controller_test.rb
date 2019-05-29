# encoding: utf-8

require "katello_test_helper"

module Katello
  class HostErrataControllerTestBase < ActionController::TestCase
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
  end

  class HostErrataControllerBulkErrataTest < HostErrataControllerTestBase
    def setup
      super
      @controller = ::Katello::Api::V2::HostErrataController.new
      @controller.instance_variable_set(:@host, @host)
      @errata = katello_errata(:security)
      @host.content_facet.bound_repositories << @errata.repositories.first
      @bugfix = katello_errata(:bugfix)
    end

    def test_search_bulk_errata
      bulk_params = {
        :included => {
          :search => "errata_id = #{@errata.errata_id}"
        }
      }
      result = @controller.find_bulk_errata_ids(bulk_params)

      assert_includes result, @errata.errata_id
    end

    def test_search_bulk_errata_exclude
      bulk_params = {
        :included => {
          :search => "issued <  Yesterday"
        },
        :excluded => {
          :ids => [@bugfix.errata_id]
        }
      }
      result = @controller.find_bulk_errata_ids(bulk_params)

      refute_includes result, @bugfix.errata_id
      assert_includes result, @errata.errata_id
    end

    def test_search_bulk_errata_ids
      bulk_params = {
        :included => {
          :ids => [@bugfix.errata_id]
        }
      }
      result = @controller.find_bulk_errata_ids(bulk_params)

      refute_includes result, @errata.errata_id
      assert_includes result, @bugfix.errata_id
    end

    def test_search_bulk_errata_ids_excluded
      bulk_params = {
        :included => {
          :ids => [@bugfix.errata_id, @errata.errata_id]
        },
        :excluded => {
          :ids => [@bugfix.errata_id]
        }
      }
      result = @controller.find_bulk_errata_ids(bulk_params)

      refute_includes result, @bugfix.errata_id
      assert_includes result, @errata.errata_id
    end

    def test_excludes_only_case
      bulk_params = {
        :excluded => {
          :ids => [@bugfix.errata_id]
        }
      }
      exception = assert_raises(HttpErrors::BadRequest) do
        @controller.find_bulk_errata_ids(bulk_params)
      end
      assert_match(/No errata has been specified/, exception.message)
    end
  end

  class Api::V2::HostErrataControllerTest < HostErrataControllerTestBase
    def test_index
      response = get :index, params: { :host_id => @host_dev.id }

      assert_nil JSON.parse(response.body)['error']
      assert_response :success
      assert_template 'api/v2/host_errata/index'
    end

    def test_index_without_content_facet
      get :index, params: { :host_id => @host_without_content_facet.id }

      assert_response :success
      assert_template 'api/v2/host_errata/index'
    end

    def test_index_other_env
      @default_content_view = katello_content_views(:acme_default)
      @library = katello_environments(:library)
      get :index, params: { :host_id => @host_dev.id, :content_view_id => @default_content_view.id, :environment_id => @library.id }

      assert_response :success
      assert_template 'api/v2/host_errata/index'
    end

    def test_apply
      assert_async_task ::Actions::Katello::Host::Erratum::Install do |host, errata|
        host.id == @host.id && errata == %w(RHSA-1999-1231)
      end

      put :apply, params: { :host_id => @host.id, :errata_ids => %w(RHSA-1999-1231) }

      assert_response :success
    end

    def test_applicability
      assert_async_task ::Actions::Katello::Host::GenerateApplicability do |hosts, use_queue|
        hosts == [@host] && use_queue == false
      end

      put :applicability, params: { :host_id => @host.id }

      assert_response :success
    end

    def test_apply_unknown_errata
      put :apply, params: { :host_id => @host.id, :errata_ids => %w(non-existant-errata) }
      assert_response 404
    end

    def test_apply_protected
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:apply, good_perms, bad_perms) do
        user = User.current
        as_admin do
          @host.update_attribute(:organization, taxonomies(:organization1))
          @host.update_attribute(:location, taxonomies(:location1))
          user.organizations = [@host.organization]
          user.locations = [@host.location]
        end
        put :apply, params: { :host_id => @host.id, :errata_ids => %w(RHSA-1999-1231) }
      end
    end
  end
end
