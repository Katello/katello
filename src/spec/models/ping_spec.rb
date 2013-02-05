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

require 'webmock'
include WebMock::API


describe Ping do

  it "should ping candlepin, elasticsearch, thumbslug, candlepin_oauth, and katello-jobs", :headpin => true do

    # candlepin - without oauth
    stub_request(:get, "#{Katello.config.candlepin.url}/status")

    # elastic search - without oauth
    stub_request(:get, "#{Katello.config.elastic_url}/_status")

    # thumbslug - without authentication
    stub_request(:get, "#{Katello.config.thumbslug_url}/ping").to_raise(OpenSSL::SSL::SSLError)

    # candlepin - with oauth
    Resources::Candlepin::CandlepinPing.stub!(:ping).and_return()

    # katello jobs
    Ping.should_receive(:system).with("/sbin/service katello-jobs status").and_return(true)

    result = Ping.ping()
    result[:result].should == "ok"
  end

  it "should ping pulp, candlepin, elasticsearch, pulp_oauth, candlepin_oauth, foreman_oauth, and katello-jobs", :katello => true do

    # pulp - without oauth
    stub_request(:get, "#{Katello.config.pulp.url}/services/status/") # gotta have that trailing slash

    # candlepin - without oauth
    stub_request(:get, "#{Katello.config.candlepin.url}/status")

    # elastic search - without oauth
    stub_request(:get, "#{Katello.config.elastic_url}/_status")

    # pulp - with oauth
    Runcible::Resources::User.stub!(:retrieve_all).and_return()

    # candlepin - with oauth
    Resources::Candlepin::CandlepinPing.stub!(:ping).and_return()

    # foreman - with oauth
    Resources::ForemanModel.stub!(:header).and_return(true)
    Resources::Foreman::Home.stub!(:status).and_return()

    # katello jobs
    Ping.should_receive(:system).with("/sbin/service katello-jobs status").and_return(true)

    Ping.should_receive(:pulp_without_oauth).and_return(nil)

    result = Ping.ping()
    result[:result].should == "ok"
  end
end
