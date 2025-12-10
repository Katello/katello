require 'katello_test_helper'

class ContentHostsRoutingTest < ActionDispatch::IntegrationTest
  def setup
    @host = hosts(:one)
  end

  test 'redirect content_hosts index to new hosts index' do
    get '/content_hosts'
    assert_response :redirect
    assert_redirected_to new_hosts_index_page_path
  end

  test 'redirect content_hosts show with database ID to host details' do
    get "/content_hosts/#{@host.id}"
    assert_response :redirect
    assert_redirected_to host_details_page_path(@host.id)
  end

  test 'redirect content_hosts show with hostname to host details' do
    get "/content_hosts/#{@host.name}"
    assert_response :redirect
    assert_redirected_to host_details_page_path(@host.name)
  end

  test 'redirect content_hosts errata tab to host details with Content/errata fragment' do
    get "/content_hosts/#{@host.id}/errata"
    assert_response :redirect
    expected_path = "#{host_details_page_path(@host.id)}#/Content/errata"
    assert_redirected_to expected_path
  end

  test 'redirect content_hosts packages tab to host details with Content/packages fragment' do
    get "/content_hosts/#{@host.name}/packages"
    assert_response :redirect
    expected_path = "#{host_details_page_path(@host.name)}#/Content/packages"
    assert_redirected_to expected_path
  end

  test 'redirect content_hosts debs tab to host details with Content/debs fragment' do
    get "/content_hosts/#{@host.id}/debs"
    assert_response :redirect
    expected_path = "#{host_details_page_path(@host.id)}#/Content/debs"
    assert_redirected_to expected_path
  end

  test 'redirect content_hosts module-streams tab to host details with Content/module-streams fragment' do
    get "/content_hosts/#{@host.id}/module-streams"
    assert_response :redirect
    expected_path = "#{host_details_page_path(@host.id)}#/Content/module-streams"
    assert_redirected_to expected_path
  end

  test 'redirect content_hosts traces tab to host details with Traces fragment' do
    get "/content_hosts/#{@host.id}/traces"
    assert_response :redirect
    expected_path = "#{host_details_page_path(@host.id)}#/Traces"
    assert_redirected_to expected_path
  end

  test 'redirect content_hosts with hostname containing dots' do
    hostname_with_dots = 'host.example.com'
    get "/content_hosts/#{hostname_with_dots}"
    assert_response :redirect
    assert_redirected_to host_details_page_path(hostname_with_dots)
  end

  test 'redirect content_hosts tab with hostname containing dots' do
    hostname_with_dots = 'host.example.com'
    get "/content_hosts/#{hostname_with_dots}/errata"
    assert_response :redirect
    expected_path = "#{host_details_page_path(hostname_with_dots)}#/Content/errata"
    assert_redirected_to expected_path
  end
end
