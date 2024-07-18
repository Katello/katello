require 'katello_test_helper'

class SmartProxiesControllerTest < ActionController::TestCase
  include VCR::TestCase

  def models
    @smart_proxy = FactoryBot.create(:smart_proxy, :with_pulp3)
  end

  def proxy_storage_response
    response = {"pulp_dir" => {"filesystem" => "/dev/vda3", "1k-blocks" => 39_603_264, "used" => 30_135_856, "available" => 7_432_652,
                               "percent" => "81%", "mounted" => "/", "path" => "/var/lib/pulp", "size" => "kilobyte"},
                "pulp_content_dir" => {"filesystem" => "/dev/vda2", "1k-blocks" => 499_656, "used" => 196_060, "available" => 266_900,
                                       "percent" => "43%", "mounted" => "/dev/vda2", "path" => "/var/lib/pulp/content", "size" => "kilobyte"},
                "mongodb_dir" => {"filesystem" => "/dev/vda3", "1k-blocks" => 39_603_264, "used" => 30_135_856, "available" => 7_432_652,
                                  "percent" => "81%", "mounted" => "/", "path" => "/var/lib/mongodb", "size" => "kilobyte"}}
    ProxyAPI::Pulp.any_instance.stubs(:pulp_storage).returns(response)
  end

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
    proxy_storage_response
  end

  def test_smart_proxy_pulp_storage
    get :pulp_storage, params: { :id => @smart_proxy.id }
    assert_response :success
  end
end
