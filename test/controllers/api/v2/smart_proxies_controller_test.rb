require 'katello_test_helper'

class Api::V2::SmartProxiesControllerTest < ActionController::TestCase
  def models
    @smart_proxy = FactoryBot.create(:smart_proxy, :features => [FactoryBot.create(:feature, name: 'Pulp')])
    @http_proxy = http_proxies(:myhttpproxy)
  end

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
  end

  def test_update
    put :update, params: { smart_proxy: { http_proxy_id: @http_proxy.id, :name => 'foobar', :download_policy => 'immediate' }, :id => @smart_proxy.id }
    assert_response :success
    @smart_proxy.reload
    assert_equal @smart_proxy.http_proxy_id, @http_proxy.id
    assert_equal @smart_proxy.name, 'foobar'
    assert_equal @smart_proxy.download_policy, 'immediate'
  end
end
