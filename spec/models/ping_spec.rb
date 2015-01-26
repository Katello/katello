# Copyright 2014 Red Hat, Inc.
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
  describe Ping do
    describe "#ping" do
      before do
        # candlepin - without oauth
        stub_request(:get, "#{Katello.config.candlepin.url}/status")

        # elastic search - without oauth
        stub_request(:get, "#{Katello.config.elastic_url}/_status")

        # candlepin - with oauth
        Resources::Candlepin::CandlepinPing.stubs(:ping).returns
      end

      describe "katello mode" do
        subject { Ping.ping[:status] }
        it "(katello)" do
          # pulp - without oauth
          stub_request(:get, "#{Katello.config.pulp.url}/services/status/") # gotta have that trailing slash

          # pulp - with oauth
          Katello.pulp_server.resources.user.stubs(:retrieve_all).returns([])

          Ping.expects(:pulp_without_oauth).returns(nil)

          subject.must_be_instance_of(String)
        end
      end
    end
  end
end
