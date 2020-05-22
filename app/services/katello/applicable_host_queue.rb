module Katello
  class ApplicableHostQueue
    def self.batch_size
      ::Setting::Content.find_by(name: "applicability_batch_size").value
    end

    def self.queue_depth
      ::Katello::HostQueueElement.all.size
    end

    def self.push_host(host_id)
      HostQueueElement.create!({ host_id: host_id })
    end

    def self.pop_hosts(amount = self.batch_size)
      queue = HostQueueElement.group(:host_id).select("MIN(created_at) as created_at, host_id").limit(amount)
      HostQueueElement.where(host_id: queue.map(&:host_id)).delete_all
      queue
    end
  end
end
