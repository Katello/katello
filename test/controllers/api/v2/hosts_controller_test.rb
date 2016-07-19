require 'katello_test_helper'

class Api::V2::HostsControllerTest < ActionController::TestCase
  def setup
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
  end

  def models
    @content_view = katello_content_views(:acme_default)
    @environment = katello_environments(:library)
    @system = katello_systems(:simple_server)
    @host = FactoryGirl.create(:host)
  end

  def host_index_and_show(host)
    get :index
    assert_response :success

    Katello::Candlepin::Consumer.any_instance.stubs(:compliance_reasons).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:installed_products).returns([])

    get :show, :id => host.id
    assert_response :success
  end

  def host_show(host, smart_proxy)
    Katello::Candlepin::Consumer.any_instance.stubs(:compliance_reasons).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:installed_products).returns([])

    get :show, :id => host.id
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal smart_proxy.id, response["content_source_id"]
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

  def test_with_smartproxy
    host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                              :lifecycle_environment => @environment, :content_host => @system)
    smart_proxy = FactoryGirl.create(:smart_proxy, :features => [FactoryGirl.create(:feature, name: 'Pulp')])
    host.update_column(:content_source_id, smart_proxy.id)
    host_show(host, smart_proxy)
  end

  def test_create_with_permitted_attributes
    cf_attrs = {:content_view_id => @content_view.id, :lifecycle_environment_id => @environment.id}
    attrs = @host.clone.attributes.merge("name" => "contenthost", "content_facet_attributes" => cf_attrs)

    assert_difference('Host.count') do
      post :create, attrs
      assert_response :success
    end
  end

  def test_create_with_unpermitted_attributes
    cf_attrs = {:content_view_id => @content_view.id,
                :lifecycle_environment_id => @environment.id,
                :uuid => "thisshouldntbeabletobesetbyuser"
               }
    attrs = @host.clone.attributes.merge("name" => "contenthost1", "content_facet_attributes" => cf_attrs)

    post :create, attrs
    assert_response :success # the uuid is simply filtered out which allows the host to be still saved
    refute Katello::Host::ContentFacet.where(:uuid => cf_attrs[:uuid]).exists?
  end
end
