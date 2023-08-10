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
    @dev = katello_environments(:dev)
    @cv2 = katello_content_views(:library_view_no_version)
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

  def test_no_content_view_environments
    host = FactoryBot.create(:host, :with_content, :with_subscription)
    assert_empty host.content_facet.content_view_environments

    host_index_and_show(host)
  end

  def test_content_facet_attributes_assigned_as_cve
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    Katello::Host::SubscriptionFacet.any_instance.expects(:backend_update_needed?).returns(false)
    orig_cves = host.content_facet.content_view_environment_ids.to_a
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_id => @cv2.id,
        :lifecycle_environment_id => @dev.id
      }
    }, session: set_session_user
    assert_response :success
    host.content_facet.reload
    target_cve = ::Katello::ContentViewEnvironment.where(:content_view_id => @cv2.id,
      :environment_id => @dev.id).first
    assert_equal 1, host.content_facet.content_view_environment_ids.count
    refute_equal orig_cves, host.content_facet.content_view_environment_ids
    assert_equal target_cve, host.content_facet.content_view_environments.first
  end

  def test_host_update_with_env_only
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :lifecycle_environment_id => @dev.id
      }
    }, session: set_session_user
    assert_response :error
  end

  def test_host_update_with_cv_only
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_id => @cv2.id
      }
    }, session: set_session_user
    assert_response :error
  end

  def test_host_update_with_invalid_env
    host = FactoryBot.create(:host, :with_content, :with_subscription,
                              :content_view => @content_view, :lifecycle_environment => @environment)
    @dev.destroy
    put :update, params: {
      :id => host.id,
      :content_facet_attributes => {
        :content_view_id => @cv2.id,
        :lifecycle_environment_id => @dev.id
      }
    }, session: set_session_user
    assert_response :error
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
