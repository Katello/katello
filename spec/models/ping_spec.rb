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
