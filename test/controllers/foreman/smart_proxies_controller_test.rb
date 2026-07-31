require 'katello_test_helper'

class SmartProxiesControllerTest < ActionController::TestCase
  include VCR::TestCase

  def models
    @smart_proxy = FactoryBot.create(:smart_proxy, :with_pulp3)
  end

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
  end

  def test_smart_proxy_pulp_storage
    SmartProxy.any_instance.stubs(:pulp_disk_usage).returns([
      {
        'description' => 'Pulp Storage',
        'total' => 39_603_264,
        'used' => 30_135_856,
        'free' => 7_432_652,
        'percentage' => 76,
        'label' => 'pulp_dir'
      }.with_indifferent_access
    ])
    get :pulp_storage, params: { :id => @smart_proxy.id }
    assert_response :success
  end
end
