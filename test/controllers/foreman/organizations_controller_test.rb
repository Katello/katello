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

    Organization.any_instance.stubs(:redhat_repository_url)
    Organization.any_instance.stubs(:default_content_view).returns(OpenStruct.new(id: 1))
    Organization.any_instance.stubs(:library).returns(OpenStruct.new(id: 10))

    create_task = @controller.expects(:sync_task).with do |action_class, org|
      org.save && action_class == ::Actions::Katello::Organization::Create
    end
    create_task.returns(build_task_stub)

    put :create, :commit => "Submit", :organization => { :name => name }

    org = Organization.find_by(:name => name)
    assert org
    assert_redirected_to edit_organization_path(:id => org.to_param)
    assert_equal session[:organization_id], org.id
  end
end
