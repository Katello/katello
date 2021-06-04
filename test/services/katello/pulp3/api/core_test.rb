require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      module Api
        class CoreTest < ActiveSupport::TestCase
          include Katello::Pulp3Support

          def setup
            @primary = SmartProxy.pulp_primary
          end

          def test_with_excon
            default = Faraday.default_adapter
            Faraday.default_adapter = :excon

            assert Katello::Pulp3::Api::Core.new(@primary).tasks_api.list(limit: 1)
          ensure
            Faraday.default_adapter = default
          end

          def test_with_net_http
            default = Faraday.default_adapter
            Faraday.default_adapter = :net_http

            assert Katello::Pulp3::Api::Core.new(@primary).tasks_api.list(limit: 1)
          ensure
            Faraday.default_adapter = default
          end

          def test_logging_request_id_set_in_header
            cid = 'abc123'
            ::Logging.mdc['request'] = cid
            client = Katello::Pulp3::Api::Core.new(@primary).core_api_client
            assert_equal cid, client.default_headers['Correlation-ID']
          end

          def test_logging_request_id_not_set_in_header
            ::Logging.mdc['request'] = nil
            client = Katello::Pulp3::Api::Core.new(@primary).core_api_client
            assert_nil client.default_headers['Correlation-ID']
          end

          def test_cancel_task
            core = Katello::Pulp3::Api::Core.new(@primary)
            task = core.tasks_api.list.results.first

            assert_nothing_raised do
              core.cancel_task(task.pulp_href)
            end
          end
        end
      end
    end
  end
end
