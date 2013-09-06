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
require 'helpers/config_helper_spec'

describe Ping do

  describe "#ping" do
    before do
      # candlepin - without oauth
      stub_request(:get, "#{Katello.config.candlepin.url}/status")

      # elastic search - without oauth
      stub_request(:get, "#{Katello.config.elastic_url}/_status")

      # candlepin - with oauth
      Resources::Candlepin::CandlepinPing.stub!(:ping).and_return()

      # katello jobs
      Ping.should_receive(:system).with("/sbin/service katello-jobs status").and_return(true)
    end

    context "headpin mode", :headpin => true do
      before do
        stub_headpin_mode

        # thumbslug - without authentication
        stub_request(:get, "#{Katello.config.thumbslug_url}/ping").to_raise(OpenSSL::SSL::SSLError)
      end

      subject { Ping.ping[:result] }
      it(:headpin => true) { should eql('ok') }
    end

    context "katello mode", :katello => true do
      before do
        # pulp - without oauth
        stub_request(:get, "#{Katello.config.pulp.url}/services/status/") # gotta have that trailing slash

        # pulp - with oauth
        Katello.pulp_server.resources.user.stub!(:retrieve_all).and_return([])

        Ping.should_receive(:pulp_without_oauth).and_return(nil)
      end

      subject {Ping.ping[:result]}
      it(:katello => true) { should eql('ok') }
    end

  end
end
