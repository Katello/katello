require 'katello_test_helper'

class Api::V2::SmartProxiesControllerTest < ActionController::TestCase
  def models
    @smart_proxy = FactoryGirl.create(:smart_proxy, :features => [FactoryGirl.create(:feature, name: 'Pulp')])
  end

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
  end

  def test_update
    put :update, :name => 'foobar', :download_policy => 'immediate', :id => @smart_proxy.id
    assert_response :success
  end
end
