module Katello
  module Resources
    module Candlepin
      class Admin < CandlepinResource
        extend AdminResource

        def self.queues
          response = get("#{path}/queues")
          JSON.parse(response.body).first
        end

        def self.queue_depth(queue_name)
          queue = queues.select { |q| q['queueName'] == queue_name }
          queue['pendingMessageCount'].to_i
        rescue
          nil # be graceful when candlepin is down
        end
      end
    end
  end
end
