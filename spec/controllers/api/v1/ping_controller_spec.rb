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

require 'spec_helper'
require 'webmock/rspec'

describe Api::V1::PingController do
  include LoginHelperMethods

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
    login_user
    @request.env["HTTP_ACCEPT"] = "application/json"
  end

  def resource_list
    get :resource_list
  end

  def json(response)
    JSON.parse(response.body)
  end

  context "system_status" do

    it "should reflect the correct information", :headpin => true do
      Katello.config.stub!(:app_name).and_return("Headpin")
      Katello.config.stub!(:katello_version).and_return("12")
      get :server_status
      json(response).should include "release" => "Headpin"
      json(response).should include "version" => "12"
    end

    it "should reflect the correct information", :katello => true do
      Katello.config.stub!(:app_name).and_return("Katello")
      Katello.config.stub!(:katello_version).and_return("12")
      get :server_status
      json(response).should include "release" => "Katello"
      json(response).should include "version" => "12"
    end

  end

  context "ping" do

    it "should call Ping.ping()", :headpin => true do
      Ping.should_receive(:ping).once.and_return(:headpin_ping_ok)
      get :index
      response.body.should == :headpin_ping_ok.to_json
    end

    it "should call Ping.ping()", :katello => true do
      Ping.should_receive(:ping).once.and_return(:katello_ping_ok)
      get :index
      response.body.should == :katello_ping_ok.to_json
    end

  end

  context "version" do

    it "should get back the correct app name for katello", :katello => true do
      get :version
      response.body.should == { :name => "katello", :version => Katello.config.katello_version }.to_json
    end

    it "should get back the correct app name for headpin", :headpin => true do
      get :version
      response.body.should == { :name => "headpin", :version => Katello.config.katello_version }.to_json
    end

  end

end
