require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      module Api
        class ClientApiTest < ActiveSupport::TestCase
          include Katello::Pulp3Support
          def setup
            @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          end

          client_apis = [
            Katello::Pulp3::Api::Yum, Katello::Pulp3::Api::Apt,
            Katello::Pulp3::Api::ContentGuard, Katello::Pulp3::Api::Docker,
            Katello::Pulp3::Api::File]

          client_apis.each do |input|
            test "#{input} sets correlation id in header if request id" do
              cid = 'abc123'
              ::Logging.mdc['request'] = cid
              client = input.new(@primary).api_client
              assert_equal cid, client.default_headers['Correlation-ID']
            end
          end

          client_apis.each do |input|
            test "#{input} no correlation id in header if no request id" do
              ::Logging.mdc['request'] = nil
              client = input.new(@primary).api_client
              assert_nil client.default_headers['Correlation-ID']
            end
          end
        end
      end
    end
  end
end
