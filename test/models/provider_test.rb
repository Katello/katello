require 'katello_test_helper'

module Katello
  class ProviderTest < ActiveSupport::TestCase
    class OwnerUpstreamUpdateTest < ActiveSupport::TestCase
      let(:provider) { katello_providers(:redhat) }
      let(:api_url) { 'http://theforeman.org/subscription/consumers/' }
      let(:expected_url) { api_url }

      def setup
        @upstream_params = { 'apiUrl' => api_url, 'idCert' => { 'key' => '', 'cert' => ''}}
        expected_params = [expected_url, "", "", nil, { :capabilities => [], :facts => { :distributor_version => Katello::Glue::Provider::DISTRIBUTOR_VERSION } }]
        Resources::Candlepin::UpstreamConsumer.expects(:update).with(*expected_params)
        Resources::Candlepin::CandlepinPing.stubs(:ping).returns('managerCapabilities' => [])
      end

      it 'calls the apiUrl in the manifest' do
        provider.owner_upstream_update(@upstream_params, {})
      end

      context 'apiUrl missing from the manifest' do
        let(:api_url) { nil }
        let(:expected_url) { 'https://subscription.rhsm.redhat.com/subscription/consumers/' }

        it 'falls back to the default' do
          provider.owner_upstream_update(@upstream_params, {})
        end
      end
    end
  end
end
