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

    put :create, params: { :commit => "Submit", :organization => { :name => name } }

    org = Organization.find_by(:name => name)
    assert org
    assert_redirected_to step2_organization_path(:id => org.to_param)
    assert_equal session[:organization_id], org.id
  end

  def test_simple_content_access_toggle
    # use org with SCA enabled
    org = Organization.first
    Organization.any_instance.stubs(:simple_content_access?).returns true
    TaxHost.any_instance.stubs(:check_for_orphans).returns false
    # assert correct task will be started
    @controller.expects(:async_task).with do |action_class, _org|
      action_class == ::Actions::Katello::Organization::SimpleContentAccess::Disable
    end
    # send request to disable SCA
    put :update, params: { id: org.id, simple_content_access: false }
  end

  def test_simple_content_access_unchanged
    # use org with SCA enabled
    org = Organization.first
    Organization.any_instance.stubs(:simple_content_access?).returns true
    TaxHost.any_instance.stubs(:check_for_orphans).returns false
    # assert SCA task is not initiated
    @controller.expects(:async_task).with do |action_class, _org|
      action_class == ::Actions::Katello::Organization::SimpleContentAccess::Disable
    end.never
    # update org and don't change SCA
    put :update, params: { id: org.id, simple_content_access: true }
  end
end
