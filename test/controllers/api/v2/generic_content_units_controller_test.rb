require "katello_test_helper"
module Katello
  class Api::V2::GenericContentUnitsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @generic = GenericContentUnit.find(katello_generic_content_units(:one).id)
      @repo = Repository.find(katello_repositories(:pulp3_python_1).id)
    end

    def setup
      setup_controller_defaults_api
      models
      setup_product_permissions
    end

    def test_content_units_required_param
      get :index, :params => {}

      assert_response :error
      assert_match "Required param content_type is missing", @response.body
    end

    def test_python_package_index
      get :index, :params => { content_type: "python_package" }

      assert_response :success
      assert_template "katello/api/v2/generic_content_units/index"

      get :index, params: { repository_id: @repo.id, content_type: "python_package" }

      assert_response :success
      assert_template "katello/api/v2/generic_content_units/index"
    end

    def test_python_package_show
      get :show, params: { id: @generic.id, content_type: "python_package" }

      assert_response :success
      assert_template "katello/api/v2/generic_content_units/show"
    end
  end
end
