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

  def test_create_with_content_view_and_lifecycle_environment
    org = FactoryBot.create(:katello_organization)
    library = FactoryBot.create(:katello_environment, :library, organization: org)
    view = FactoryBot.create(:katello_content_view, organization: org)
    view_version = FactoryBot.create(:katello_content_view_version, content_view: view)
    FactoryBot.create(:katello_content_view_environment,
                      content_view_version: view_version,
                      environment: library)

    post :create, params: {
      :hostgroup => {
        :name => 'Test HG with CV',
        :lifecycle_environment_id => library.id,
        :content_view_id => view.id,
      },
    }

    assert_response :success
    assert_equal 'Test HG with CV', assigns[:hostgroup].name
    assert_equal library.id, assigns[:hostgroup].lifecycle_environment_id
    assert_equal view.id, assigns[:hostgroup].content_view_id
  end

  def test_update_content_view_and_lifecycle_environment
    org = FactoryBot.create(:katello_organization)
    library = FactoryBot.create(:katello_environment, :library, organization: org)
    dev = FactoryBot.create(:katello_environment, name: 'Dev', organization: org, prior: library)

    view1 = FactoryBot.create(:katello_content_view, name: 'View1', organization: org)
    view2 = FactoryBot.create(:katello_content_view, name: 'View2', organization: org)

    view1_version = FactoryBot.create(:katello_content_view_version, content_view: view1)
    view2_version = FactoryBot.create(:katello_content_view_version, content_view: view2)

    FactoryBot.create(:katello_content_view_environment,
                      content_view_version: view1_version,
                      environment: library)
    FactoryBot.create(:katello_content_view_environment,
                      content_view_version: view2_version,
                      environment: dev)

    hostgroup = ::Hostgroup.create!(name: 'TestHG')
    hostgroup.lifecycle_environment_id = library.id
    hostgroup.content_view_id = view1.id
    hostgroup.save!

    put :update, params: {
      :id => hostgroup.id,
      :hostgroup => {
        :lifecycle_environment_id => dev.id,
        :content_view_id => view2.id,
      },
    }

    assert_response :success
    hostgroup.reload
    assert_equal dev.id, hostgroup.lifecycle_environment_id
    assert_equal view2.id, hostgroup.content_view_id
  end

  def test_show_includes_content_view_and_lifecycle_environment
    org = FactoryBot.create(:katello_organization)
    library = FactoryBot.create(:katello_environment, :library, organization: org)
    view = FactoryBot.create(:katello_content_view, organization: org)
    view_version = FactoryBot.create(:katello_content_view_version, content_view: view)
    FactoryBot.create(:katello_content_view_environment,
                      content_view_version: view_version,
                      environment: library)

    hostgroup = ::Hostgroup.create!(name: 'TestShowHG')
    hostgroup.lifecycle_environment_id = library.id
    hostgroup.content_view_id = view.id
    hostgroup.save!

    get :show, params: { :id => hostgroup.id }

    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal library.id, response['lifecycle_environment_id']
    assert_equal library.name, response['lifecycle_environment_name']
    assert_equal view.id, response['content_view_id']
    assert_equal view.name, response['content_view_name']
  end

  def test_create_with_content_view_environment_id
    org = FactoryBot.create(:katello_organization)
    library = FactoryBot.create(:katello_environment, :library, organization: org)
    view = FactoryBot.create(:katello_content_view, organization: org)
    view_version = FactoryBot.create(:katello_content_view_version, content_view: view)
    cve = FactoryBot.create(:katello_content_view_environment,
                            content_view_version: view_version,
                            environment: library)

    post :create, params: {
      :hostgroup => {
        :name => 'Test HG with CVE ID',
        :content_view_environment_id => cve.id,
      },
    }

    assert_response :success
    assert_equal 'Test HG with CVE ID', assigns[:hostgroup].name
    assert_equal cve.id, assigns[:hostgroup].content_facet.content_view_environment_id
    assert_equal library.id, assigns[:hostgroup].lifecycle_environment_id
    assert_equal view.id, assigns[:hostgroup].content_view_id
  end

  def test_update_with_content_view_environment_id
    org = FactoryBot.create(:katello_organization)
    library = FactoryBot.create(:katello_environment, :library, organization: org)
    dev = FactoryBot.create(:katello_environment, name: 'Dev', organization: org, prior: library)

    view1 = FactoryBot.create(:katello_content_view, name: 'View1', organization: org)
    view2 = FactoryBot.create(:katello_content_view, name: 'View2', organization: org)

    view1_version = FactoryBot.create(:katello_content_view_version, content_view: view1)
    view2_version = FactoryBot.create(:katello_content_view_version, content_view: view2)

    cve1 = FactoryBot.create(:katello_content_view_environment,
                             content_view_version: view1_version,
                             environment: library)
    cve2 = FactoryBot.create(:katello_content_view_environment,
                             content_view_version: view2_version,
                             environment: dev)

    hostgroup = ::Hostgroup.create!(name: 'TestHG')
    hostgroup.content_view_environment_id = cve1.id
    hostgroup.save!

    put :update, params: {
      :id => hostgroup.id,
      :hostgroup => {
        :content_view_environment_id => cve2.id,
      },
    }

    assert_response :success
    hostgroup.reload
    assert_equal cve2.id, hostgroup.content_facet.content_view_environment_id
    assert_equal dev.id, hostgroup.lifecycle_environment_id
    assert_equal view2.id, hostgroup.content_view_id
  end

  def test_create_with_only_content_view_fails_validation
    org = FactoryBot.create(:katello_organization)
    view = FactoryBot.create(:katello_content_view, organization: org)

    post :create, params: {
      :hostgroup => {
        :name => 'Invalid HG',
        :content_view_id => view.id,
        # Missing lifecycle_environment_id
      },
    }

    # Should fail validation - need both CV and LCE together
    assert_response 422
  end

  def test_create_with_only_lifecycle_environment_fails_validation
    org = FactoryBot.create(:katello_organization)
    library = FactoryBot.create(:katello_environment, :library, organization: org)

    post :create, params: {
      :hostgroup => {
        :name => 'Invalid HG',
        :lifecycle_environment_id => library.id,
        # Missing content_view_id
      },
    }

    # Should fail validation - need both CV and LCE together
    assert_response 422
  end
end
