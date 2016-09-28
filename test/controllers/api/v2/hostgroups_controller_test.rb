require 'katello_test_helper'

class Api::V2::HostgroupsControllerTest < ActionController::TestCase
  def setup
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
  end

  def models
    @hostgroup = hostgroups(:common)
  end

  def test_create
    post :create, :hostgroup => {:name => 'New Hostgroup'}

    assert_response :success
    assert_template 'api/v2/hostgroups/create'
    assert_equal assigns[:hostgroup].name, 'New Hostgroup'
  end

  def test_update
    put :update, :id => @hostgroup.id, :hostgroup => {:name => 'New Name'}

    assert_response :success
    assert_template 'api/v2/hostgroups/update'
    assert_equal assigns[:hostgroup].name, 'New Name'
  end
end
