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

require 'katello_test_helper'

module Katello
  describe Api::V1::PingController do

    let(:katello_ping_ok) {
      {
          :result => "ok",
          :status => {
              :pulp           => { :result => "ok", :duration_ms => "10" },
              :candlepin      => { :result => "ok", :duration_ms => "10" },
              :elasticsearch  => { :result => "ok", :duration_ms => "10" },
              :pulp_auth      => { :result => "ok", :duration_ms => "10" },
              :candlepin_auth => { :result => "ok", :duration_ms => "10" },
              :katello_jobs   => { :result => "ok", :duration_ms => "10" },
          }
      }
    }

    let(:headpin_ping_ok) {
      {
          :result => "ok",
          :status => {
              :candlepin      => { :result => "ok", :duration_ms => "10" },
              :elasticsearch  => { :result => "ok", :duration_ms => "10" },
              :candlepin_auth => { :result => "ok", :duration_ms => "10" },
              :katello_jobs   => { :result => "ok", :duration_ms => "10" },
              :thumbslug      => { :result => "ok", :duration_ms => "10" }
          }
      }
    }

    before (:each) do
      setup_controller_defaults_api
      @request.env["HTTP_ACCEPT"] = "application/json"
    end

    def resource_list
      get :resource_list
    end

    def json(response)
      JSON.parse(response.body)
    end

    context "system_status" do

      it "should reflect the correct information (headpin)" do
        Katello.config.stubs(:app_name).returns("Headpin")
        Katello.config.stubs(:katello_version).returns("12")
        get :server_status
        resp_json = json(response)
        resp_json.must_include("release", "version")
        resp_json["release"].must_equal("Headpin")
        resp_json["version"].must_equal("12")
      end

      it "should reflect the correct information (katello)" do
        Katello.config.stubs(:app_name).returns("Katello")
        Katello.config.stubs(:katello_version).returns("12")
        get :server_status
        resp_json = json(response)
        resp_json.must_include("release", "version")
        resp_json["release"].must_equal("Katello")
        resp_json["version"].must_equal("12")
      end

    end

    context "ping" do

      it "should call Ping.ping() (headpin)" do
        Ping.expects(:ping).once.returns(:headpin_ping_ok)
        get :index
        response.body.must_equal :headpin_ping_ok.to_json
      end

      it "should call Ping.ping() (katello)" do
        Ping.expects(:ping).once.returns(:katello_ping_ok)
        get :index
        response.body.must_equal :katello_ping_ok.to_json
      end

    end

    context "version" do

      it "should get back the correct app name for katello (katello)" do
        get :version
        response.body.must_equal({ :name => "katello", :version => Katello.config.katello_version }.to_json)
      end
      # TODO: Fix this for headpin
      # it "should get back the correct app name for headpin(headpin)" do
      #   get :version
      #   response.body.must_equal({ :name => "headpin", :version => Katello.config.katello_version }.to_json)
      # end

    end

  end
end
