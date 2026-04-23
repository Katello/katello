module Katello
  class ApplicableHostQueue
    def self.batch_size
      Setting["applicability_batch_size"]
    end

    def self.queue_depth
      ::Katello::HostQueueElement.all.size
    end

    def self.push_hosts(ids)
      return if ids.empty?

      HostQueueElement.insert_all(ids.map { |host_id| { host_id: host_id } }, unique_by: :host_id)
      ActiveSupport::Notifications.instrument("applicability_push_hosts")
    end

    def self.pop_hosts(amount = self.batch_size)
      HostQueueElement.transaction do
        elements = HostQueueElement.order(:id).select(:id, :host_id).limit(amount).lock

        host_ids = elements.map(&:host_id)
        yield(host_ids) if block_given?

        elements.delete_all
        host_ids
      end
    end
  end
end
