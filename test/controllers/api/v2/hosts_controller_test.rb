require 'katello_test_helper'

class Api::V2::HostsControllerTest < ActionController::TestCase
  def setup
    setup_foreman_routes
    login_user(User.find(users(:admin)))
    models
  end

  def models
    @content_view = katello_content_views(:acme_default)
    @environment = katello_environments(:library)
    @system = katello_systems(:simple_server)
  end

  def host_index_and_show(host)
    get :index
    assert_response :success

    Katello::Candlepin::Consumer.any_instance.stubs(:compliance_reasons).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:installed_products).returns([])

    get :show, :id => host.id
    assert_response :success
  end

  def test_content_and_subscriptions
    host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                              :lifecycle_environment => @environment, :content_host => @system)
    host_index_and_show(host)
  end

  def test_with_content
    host = FactoryGirl.create(:host, :with_content, :content_view => @content_view,
                              :lifecycle_environment => @environment, :content_host => @system)
    host_index_and_show(host)
  end

  def test_with_subscriptions
    host = FactoryGirl.create(:host, :with_subscription, :content_host => @system)
    host_index_and_show(host)
  end
end
