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

  def test_parameters_included_in_hostgroup_show
    get :show, params: { :id => hostgroups(:common).to_param }
    assert_response :success
    assert_template 'katello/api/v2/hostgroups_extensions/show'
    response = JSON.parse(@response.body)
    assert response.key?('parameters')
  end

  test_attributes :pid => '70fe5df8-8917-4a46-b37a-708f449fe749'
  def test_show_content_attributes
    content_fields = %w[
      content_source_id
      content_source_name
      content_view_id
      content_view_name
      lifecycle_environment_id
      lifecycle_environment_name
    ].sort
    get :show, params: { :id => hostgroups(:common).to_param }
    assert_response :success
    assert_template 'katello/api/v2/hostgroups_extensions/show'
    response = JSON.parse(@response.body)
    assert_equal content_fields, response.keys.select { |key| content_fields.include?(key) }.sort
  end

  test_attributes :pid => '39a6273e-8301-449a-a9d3-e3b61cda1e81'
  def test_create
    content_source_id = smart_proxies(:four).id
    post :create, params: { :hostgroup => { :name => 'New Hostgroup', :content_source_id => content_source_id } }

    assert_response :success
    assert_template 'api/v2/hostgroups/create'
    assert_equal 'New Hostgroup', assigns[:hostgroup].name
    assert_equal content_source_id, assigns[:hostgroup].content_source_id
  end

  test_attributes :pid => '02ef1340-a21e-41b7-8aa7-d6fdea196c16'
  def test_update
    content_source_id = smart_proxies(:four).id
    put :update, params: { :id => @hostgroup.id, :hostgroup => { :name => 'New Name', :content_source_id => content_source_id } }

    assert_response :success
    assert_template 'api/v2/hostgroups/update'
    assert_equal 'New Name', assigns[:hostgroup].name
    assert_equal content_source_id, assigns[:hostgroup].content_source_id
  end
end
