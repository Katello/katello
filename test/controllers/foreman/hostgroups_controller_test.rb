require 'katello_test_helper'

class HostgroupsControllerTest < ActionController::TestCase
  def models
    @library      = katello_environments(:library)
    @library_view = katello_content_views(:library_view)
  end

  def setup
    setup_controller_defaults(false, false)
    login_user(User.find(users(:admin)))
    models
  end

  def test_new
    get :new

    assert_response :success
  end

  def test_create
    post :create, :hostgroup => {:name => "foobar", :content_view_id => @library_view.id,
                                 :lifecycle_environment_id => @library.id}

    assert_equal 1, Hostgroup.where(:name => "foobar").count
    assert_response 302
  end
end
