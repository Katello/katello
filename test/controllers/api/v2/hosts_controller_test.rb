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
    @host = FactoryBot.create(:host)
  end

  def host_index_and_show(host)
    get :index
    assert_response :success

    get :show, params: { :id => host.id }
    assert_response :success
  end

  def host_show(host, smart_proxy)
    get :show, params: { :id => host.id }
    response = ActiveSupport::JSON.decode(@response.body)

    assert_equal smart_proxy.id, response["content_facet_attributes"]["content_source_id"]
    assert_response :success
  end

  def test_content_and_subscriptions
    host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                              :lifecycle_environment => @environment)
    host_index_and_show(host)
  end

  def test_with_content
    host = FactoryBot.create(:host, :with_content, :content_view => @content_view,
                              :lifecycle_environment => @environment)
    host_index_and_show(host)
  end

  def test_with_subscriptions
    host = FactoryBot.create(:host, :with_subscription)
    host_index_and_show(host)
  end

  def test_update_subscription_facet
    Katello::Host::SubscriptionFacet.any_instance.stubs(:backend_update_needed?).returns(false)

    Katello::Candlepin::Consumer.any_instance.stubs(:compliance_reasons).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:virtual_host).returns(nil)
    Katello::Candlepin::Consumer.any_instance.stubs(:virtual_guests).returns([])
    Katello::Candlepin::Consumer.any_instance.stubs(:installed_products).returns([])

    host = FactoryBot.create(:host, :with_subscription)
    host.subscription_facet.update!(:autoheal => true,
                                               :installed_products_attributes => [{:product_name => 'foo', :version => '6', :product_id => '69'}])

    put :update, params: { :id => host.id, :subscription_facet_attributes => {:autoheal => false} }

    assert_response :success

    refute host.reload.subscription_facet.reload.autoheal
    assert_equal 'foo', host.subscription_facet.installed_products.first.name
  end

  def test_with_smartproxy
    smart_proxy = FactoryBot.create(:smart_proxy, :features => [FactoryBot.create(:feature, name: 'Pulp')])
    host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                              :lifecycle_environment => @environment, :content_source => smart_proxy)
    host_show(host, smart_proxy)
  end

  def test_create_with_permitted_attributes
    cf_attrs = {:content_view_id => @content_view.id, :lifecycle_environment_id => @environment.id}
    sf_attrs = {:purpose_addons => ["Addon"]}
    attrs = @host.clone.attributes.merge("name" => "contenthost", "content_facet_attributes" => cf_attrs, "subscription_facet_attributes" => sf_attrs).compact!

    assert_difference('Host.unscoped.count') do
      post :create, params: attrs
      assert_response :success
    end
  end

  def test_create_with_unpermitted_attributes
    cf_attrs = {:content_view_id => @content_view.id,
                :lifecycle_environment_id => @environment.id,
                :uuid => "thisshouldntbeabletobesetbyuser"
               }
    attrs = @host.clone.attributes.merge("name" => "contenthost1", "content_facet_attributes" => cf_attrs).compact!

    post :create, params: attrs
    assert_response :success # the uuid is simply filtered out which allows the host to be still saved
    refute Katello::Host::ContentFacet.where(:uuid => cf_attrs[:uuid]).exists?
  end

  def test_create_purpose_addons
    sf_attrs = {:purpose_addons => ["Addon", katello_purpose_addons(:addon).name]}
    attrs = @host.clone.attributes.merge("name" => "host", "subscription_facet_attributes" => sf_attrs)

    post :create, params: attrs

    host_id = JSON.parse(response.body)["id"]
    host = Host.find(host_id)
    addon_names = host.subscription_facet.purpose_addons.pluck(:name)

    assert_equal addon_names.sort, sf_attrs[:purpose_addons].sort
    assert_response :success
  end
end

module Katello
  class Api::V2::HostsControllerTest < ActionController::TestCase
    include Support::CapsuleSupport

    def setup
      setup_controller_defaults_api
      set_ca_file
      models
    end

    def models
      @proxy = proxy_with_pulp
      @proxy_no_pulp = smart_proxies(:one)
    end

    def test_change_proxy
      get :change_proxy, params: { smart_proxy_id: @proxy.id }
      assert_equal 200, response.status
    end

    def test_cp_proxy_not_found
      get :change_proxy, params: { smart_proxy_id: 0 }
      assert_equal 404, response.status
      assert_includes response.body, "Couldn't find SmartProxy with 'id'=0"
    end

    def test_cp_not_pulp_primary
      get :change_proxy, params: { smart_proxy_id: @proxy_no_pulp.id }
      assert_equal 422, response.status
      assert_includes response.body, "Pulp 3 is not enabled on Smart proxy!"
    end

    def test_cp_organization_not_found
      get :change_proxy, params: { organization_id: 0, smart_proxy_id: @proxy.id }
      assert_equal 404, response.status
      assert_includes response.body, "Organization with id 0 not found"
    end

    def test_cp_location_not_found
      get :change_proxy, params: { location_id: 0, smart_proxy_id: @proxy.id }
      assert_equal 404, response.status
      assert_includes response.body, "Location with id 0 not found"
    end

    def test_cp_hostgroup_not_found
      get :change_proxy, params: { hostgroup_id: 0, smart_proxy_id: @proxy.id }
      assert_equal 404, response.status
      assert_includes response.body, "Couldn't find Hostgroup with 'id'=0"
    end

    def test_cp_without_openscap
      get :change_proxy, params: { smart_proxy_id: @proxy.id }
      assert_equal 200, response.status
      refute_includes response.body, "openscap_proxy_id"
    end

    def test_cp_with_openscap
      proxy = FactoryBot.create(:smart_proxy, features: [FactoryBot.create(:feature, name: 'Openscap')])
      with_pulp3_features(proxy)

      get :change_proxy, params: { smart_proxy_id: proxy.id }
      assert_equal 200, response.status
      assert_includes response.body, "\"openscap_proxy_id\":#{proxy.id}"
    end

    def test_cp_permissions
      refute_authorized(permission: [:view_hosts], action: :change_proxy, request: -> { get :change_proxy }, organizations: [])
    end
  end
end
