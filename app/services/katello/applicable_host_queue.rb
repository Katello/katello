module Katello
  class ApplicableHostQueue
    def self.batch_size
      Setting["applicability_batch_size"]
    end

    def self.queue_depth
      ::Katello::HostQueueElement.all.size
    end

    def self.push_hosts(ids)
      HostQueueElement.import ids.map { |host_id| { host_id: host_id } }, validate: false
    end

    def self.pop_hosts(amount = self.batch_size)
      queue = HostQueueElement.group(:host_id).select("MIN(created_at) as created_at, host_id").limit(amount)
      HostQueueElement.where(host_id: queue.map(&:host_id)).delete_all
      queue
    end
  end
end
