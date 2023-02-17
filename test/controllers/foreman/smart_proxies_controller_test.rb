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

  def proxy_status_response
    response = {"known_workers" => [{"last_heartbeat" => "2016-01-20T08:17:02Z", "name" => "scheduler@katello-centos7-devel.example.com"}],
                "messaging_connection" => {"connected" => true},
                "database_connection" => {"connected" => true},
                "api_version" => "2",
                "versions" => {"platform_version" => "2.6.4"},
                "errors" => {}}
    Katello::ProxyStatus::Pulp.any_instance.stubs(:status).returns(response.to_json)
  end

  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
    models
    proxy_status_response
    proxy_storage_response
  end

  def test_smart_proxy_pulp_storage
    get :pulp_storage, params: { :id => @smart_proxy.id }
    assert_response :success
  end

  def test_smart_proxy_pulp_status
    get :pulp_status, params: { :id => @smart_proxy.id }
    assert_response :success
  end
end
