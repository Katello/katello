# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::KatelloPingControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults_api
    end

    def test_ping
      login_user(User.find(users(:admin).id))
      response = { :status => "ok",
                   :services => { :pulp => { :status => "ok",
                                             :duration_ms => "38" },
                                  :candlepin => { :status => "ok",
                                                  :duration_ms => "23" },
                                  :pulp_auth => { :status => "ok",
                                                  :duration_ms => "0" },
                                  :candlepin_auth => { :status => "ok",
                                                       :duration_ms => "0" },
                                  :katello_jobs => { :status => "ok",
                                                     :duration_ms => "0" } } }
      Katello::Ping.stubs(:ping).returns(response)
      get :index

      assert_response(:success)
      assert_template('api/v2/katello_ping/show')
    end

    def test_server_status
      get :server_status

      assert_response(:success)
      assert_template('api/v2/katello_ping/server_status')
    end
  end
end
