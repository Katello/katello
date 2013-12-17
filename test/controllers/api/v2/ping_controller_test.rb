# encoding: utf-8
#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "katello_test_helper"

module Katello
  class Api::V2::PingControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["Ping"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
    end

    def test_ping
      login_user(User.find(users(:admin)))
      response = { :status => "ok",
                   :services => { :pulp => { :status => "ok",
                                             :duration_ms => "38" },
                                             :candlepin => { :status => "ok",
                                                             :duration_ms => "23" },
                                                             :elasticsearch => { :status => "ok",
                                                                                 :duration_ms => "7" },
                                                                                 :pulp_auth => { :status => "ok",
                                                                                                 :duration_ms => "0" },
                                                                                                 :candlepin_auth => { :status => "ok",
                                                                                                                      :duration_ms => "0" },
                                                                                                                      :katello_jobs => { :status => "ok",
                                                                                                                                         :duration_ms => "0" } } }
      Ping.stubs(:ping).returns(response)
      get :index

      assert_response(:success)
      assert_template('api/v2/ping/show')
    end

    def test_server_status
      get :server_status

      assert_response(:success)
      assert_template('api/v2/ping/server_status')
    end
  end
end
