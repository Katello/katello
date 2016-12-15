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
    assert_equal smart_proxy.id, response["content_facet_attributes"]["content_source_id"]
    assert_response :success
  end

  def test_content_and_subscriptions
    host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                              :lifecycle_environment => @environment)
    host_index_and_show(host)
  end

  def test_with_content
    host = FactoryGirl.create(:host, :with_content, :content_view => @content_view,
                              :lifecycle_environment => @environment)
    host_index_and_show(host)
  end

  def test_with_subscriptions
    host = FactoryGirl.create(:host, :with_subscription)
    host_index_and_show(host)
  end

  def test_update_subscription_facet
    Katello::Host::SubscriptionFacet.any_instance.stubs(:backend_update_needed?).returns(false)

    Katello::Candlepin::Consumer.any_instance.stubs(:compliance_reasons).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:virtual_host).returns(nil)
    Katello::Candlepin::Consumer.any_instance.stubs(:virtual_guests).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:installed_products).returns([])

    host = FactoryGirl.create(:host, :with_subscription)
    host.subscription_facet.update_attributes!(:autoheal => true)

    put :update, :id => host.id, :subscription_facet_attributes => {:autoheal => false}

    assert_response :success

    refute host.reload.subscription_facet.reload.autoheal
  end

  def test_with_smartproxy
    smart_proxy = FactoryGirl.create(:smart_proxy, :features => [FactoryGirl.create(:feature, name: 'Pulp')])
    host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                              :lifecycle_environment => @environment, :content_source => smart_proxy)
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
