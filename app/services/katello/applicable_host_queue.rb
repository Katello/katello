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

      result = HostQueueElement.insert_all(ids.map { |host_id| { host_id: host_id } })
      ActiveSupport::Notifications.instrument("applicability_push_hosts") if result.rows.count > 0
    end

    DELETE_QUERY = "DELETE FROM #{Katello::HostQueueElement.table_name} WHERE id IN (%s) RETURNING host_id".freeze

    def self.pop_hosts(amount = self.batch_size)
      query = HostQueueElement.order(:id).select(:id).limit(amount)
      result = ActiveRecord::Base.connection.execute(format(DELETE_QUERY, query.to_sql))
      result.values.flatten
    end
  end
end
