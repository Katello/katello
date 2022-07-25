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

  def test_simple_content_access_disable
    # use org with SCA enabled
    org = get_organization(:organization2)
    Organization.any_instance.stubs(:simple_content_access?).returns true
    # assert correct task will be started
    @controller.expects(:sync_task).with(::Actions::Katello::Organization::SimpleContentAccess::Disable, org.id.to_s)
    # send request to disable SCA
    put :update, params: { id: org.id, simple_content_access: false }
    assert_response :found
  end

  def test_simple_content_access_enable
    # use org with SCA disabled
    org = get_organization(:organization2)
    Organization.any_instance.stubs(:simple_content_access?).returns false
    # assert correct task will be started
    @controller.expects(:sync_task).with(::Actions::Katello::Organization::SimpleContentAccess::Enable, org.id.to_s)
    # send request to enable SCA
    put :update, params: { id: org.id, simple_content_access: true }
    assert_response :found
  end

  def test_simple_content_access_unchanged
    # use org with SCA enabled
    org = get_organization(:organization2)
    Organization.any_instance.stubs(:simple_content_access?).returns true
    # assert SCA task was not initiated
    @controller.expects(:async_task).never
    # update org and don't change SCA
    put :update, params: { id: org.id, simple_content_access: true }
    assert_response :found
  end

  def test_edit_override_can_toggle
    org = get_organization(:organization2)
    Organization.any_instance.stubs(:service_level)
    Organization.any_instance.stubs(:service_levels).returns []
    Organization.any_instance.expects(:simple_content_access?).returns true
    get :edit, params: { id: org.id }
    assert_response :success
  end
end
