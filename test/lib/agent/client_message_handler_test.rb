require 'katello_test_helper'

module Katello
  module Agent
    class ClientMessageHandlerTest < ActiveSupport::TestCase
      def setup
        @host = hosts(:one)
        @details = {
          "rpm" => {

          }
        }
      end

      def test_handle_with_dispatch_history
        dispatch_history = Katello::Agent::DispatchHistory.create!(
          host_id: @host.id
        )

        content = {
          data: {
            dispatch_history_id: dispatch_history.id
          },
          result: {
            retval: {
              details: @details
            }
          }
        }

        message = stub(message_id: '12345', subject: nil, content: content.to_json)
        ClientMessageHandler.handle(message)
        dispatch_history.reload

        assert_equal @details, dispatch_history.status
      end
    end
  end
end
