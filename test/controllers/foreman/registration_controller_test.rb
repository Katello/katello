require 'katello_test_helper'

class Api::V2::RegistrationControllerTest < ActionController::TestCase
  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    Setting[:foreman_url] = 'https://foreman.example.com'
  end

  def remove_pulpcore_feature(proxy)
    pulpcore = Feature.find_by(name: SmartProxy::PULP3_FEATURE)
    proxy.smart_proxy_features.where(feature: pulpcore).destroy_all
    proxy.reload
  end

  def test_global_without_proxy_uses_pulp_primary
    proxy = SmartProxy.pulp_primary
    assert proxy.pulp3_enabled?, 'Pulp primary should have Pulpcore'

    get :global, params: { organization_id: taxonomies(:organization1).id }
    vars = assigns(:global_registration_vars)
    assert_equal proxy.rhsm_url, vars[:rhsm_url]
    assert_equal proxy.pulp_content_url, vars[:pulp_content_url]
  end

  def test_global_with_proxy_that_has_pulpcore
    proxy = FactoryBot.create(:smart_proxy, :with_pulp3, url: 'https://capsule.example.com:9090')

    @controller.stubs(:find_smart_proxy).returns(proxy)

    get :global, params: { url: proxy.url, organization_id: taxonomies(:organization1).id }
    vars = assigns(:global_registration_vars)
    assert_equal proxy.rhsm_url, vars[:rhsm_url]
    assert_equal proxy.pulp_content_url, vars[:pulp_content_url]
  end

  def test_global_with_proxy_lacking_pulpcore_falls_back_to_pulpcore_on_same_host
    registration_proxy = FactoryBot.create(:smart_proxy, url: 'https://capsule.example.com:8443')
    remove_pulpcore_feature(registration_proxy)
    refute registration_proxy.pulp3_enabled?, 'Registration proxy should not have Pulpcore'

    pulpcore_proxy = FactoryBot.create(:smart_proxy, :with_pulp3, url: 'https://capsule.example.com/pulp/api/v3/smart_proxy')
    assert pulpcore_proxy.pulp3_enabled?, 'Pulpcore proxy should have Pulpcore'

    @controller.stubs(:find_smart_proxy).returns(registration_proxy)

    get :global, params: { url: registration_proxy.url, organization_id: taxonomies(:organization1).id }
    vars = assigns(:global_registration_vars)
    assert_equal pulpcore_proxy.rhsm_url, vars[:rhsm_url]
    assert_equal pulpcore_proxy.pulp_content_url, vars[:pulp_content_url]
  end

  def test_global_with_proxy_lacking_pulpcore_and_no_fallback_raises_error
    registration_proxy = FactoryBot.create(:smart_proxy, url: 'https://lonely-capsule.example.com:8443')
    remove_pulpcore_feature(registration_proxy)
    refute registration_proxy.pulp3_enabled?, 'Registration proxy should not have Pulpcore'

    @controller.stubs(:find_smart_proxy).returns(registration_proxy)

    get :global, params: { url: registration_proxy.url, organization_id: taxonomies(:organization1).id }
    assert_response :error
    assert_match(/Pulp 3 is not enabled/, response.body)
  end
end
