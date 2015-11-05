require 'katello_test_helper'

class HostsControllerTest < ActionController::TestCase
  def permissions
    @sync_permission = :sync_products
  end

  def models
    @library = katello_environments(:library)
    @library_dev_staging_view = katello_content_views(:library_dev_staging_view)
  end

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin)))
    models
    permissions
  end

  def test_puppet_environment_for_content_view
    get :puppet_environment_for_content_view, :content_view_id => @library_dev_staging_view.id, :lifecycle_environment_id => @library.id

    assert_response :success
  end
end
