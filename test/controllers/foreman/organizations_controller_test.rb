require 'katello_test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  include Support::ForemanTasks::Task

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
  end

  def test_use_newly_created_org
    Organization.current = Organization.first
    name = "Test org"

    stub_organization_creator

    put :create, params: { :commit => "Submit", :organization => { :name => name } }

    org = Organization.find_by(:name => name)
    assert org
    assert_redirected_to step2_organization_path(:id => org.to_param)
    assert_equal session[:organization_id], org.id
  end

  def test_edit_override_can_toggle
    org = get_organization(:organization2)
    Organization.any_instance.stubs(:service_level)
    Organization.any_instance.stubs(:service_levels).returns []
    get :edit, params: { id: org.id }
    assert_response :success
  end
end
