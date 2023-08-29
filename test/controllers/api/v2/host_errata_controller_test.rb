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
      result = @controller.find_bulk_errata_ids([@host], bulk_params.to_json)

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
      result = @controller.find_bulk_errata_ids([@host], bulk_params.to_json)

      refute_includes result, @bugfix.errata_id
      assert_includes result, @errata.errata_id
    end

    def test_search_bulk_errata_ids
      bulk_params = {
        :included => {
          :ids => [@bugfix.errata_id]
        }
      }
      result = @controller.find_bulk_errata_ids([@host], bulk_params.to_json)

      refute_includes result, @errata.errata_id
      assert_includes result, @bugfix.errata_id
    end

    def test_search_bulk_errata_ids_excluded
      bulk_params = {
        :included => {
        },
        :excluded => {
          :ids => [@bugfix.errata_id]
        },
        all: true
      }
      result = @controller.find_bulk_errata_ids([@host], bulk_params.to_json)

      refute_includes result, @bugfix.errata_id
      assert_includes result, @errata.errata_id
    end

    def test_excludes_only_case
      bulk_params = {
        :excluded => {}
      }
      exception = assert_raises(HttpErrors::BadRequest) do
        @controller.find_bulk_errata_ids([@host], bulk_params.to_json)
      end
      assert_match(/No items have been specified/, exception.message)
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

    def test_index_with_include_applicable
      get :index, params: { host_id: @host_dev.id, include_applicable: true }
      assert_response :success
      assert_template 'api/v2/host_errata/index'
      cv = @controller.instance_eval { @content_view }
      env = @controller.instance_eval { @environment }
      assert cv.default?
      assert env.library?
    end

    def test_applicability
      put :applicability, params: { :host_id => @host.id }

      assert_response :success

      assert Katello::HostQueueElement.find_by(host_id: @host.id)
    end
  end
end
