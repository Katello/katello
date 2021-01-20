module Katello
  module Agent
    class BaseMessage
      attr_accessor :dispatch_history_id
      attr_reader :host_id

      def json
        {
          data: {
            consumer_id: consumer_id,
            dispatch_history_id: self.dispatch_history_id
          },
          replyto: "pulp.task",
          request: {
            args: [
              self.units,
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

      def recipient_address
        "pulp.agent.#{consumer_id}"
      end

      def consumer_id
        @consumer_id ||= ::Katello::Host::ContentFacet.where(host_id: @host_id).pluck(:uuid).first
      end
    end
  end
end
