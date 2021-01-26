module Katello
  module Agent
    class BaseMessage
      attr_accessor :dispatch_history_id, :recipient_address, :reply_to

      def json
        {
          data: {
            consumer_id: @consumer_id,
            dispatch_history_id: dispatch_history_id
          },
          replyto: reply_to,
          request: {
            args: [
              units,
              {
                importkeys: true
              }
            ],
            classname: "Content",
            cntr: [[], {}],
            kws: {},
            method: @method
          },
          routing: [
            nil,
            recipient_address
          ],
          version: "2.0"
        }
      end

      def to_s
        json.to_json
      end
    end
  end
end
