module Katello
  class ApplicableHostQueue
    DISPATCH_LOCK = 1_263_820_881
    HOST_LOCK = 1_263_820_882

    def self.batch_size
      Setting["applicability_batch_size"]
    end

    def self.queue_depth
      ::Katello::HostQueueElement.all.size
    end

    def self.push_hosts(ids)
      HostQueueElement.import ids.map { |host_id| { host_id: host_id } }, validate: false
    end

    # A fixed watermark bounds a tick even while profiles keep arriving. Only
    # acknowledge the exact selected rows, after the task has been accepted.
    def self.dispatch_batches
      cutoff = HostQueueElement.maximum(:id)
      return 0 unless cutoff

      dispatched = 0
      loop do
        count = dispatch_batch(cutoff) { |host_ids| yield host_ids }
        break if count.zero?
        dispatched += count
      end
      dispatched
    end

    def self.dispatch_batch(cutoff)
      HostQueueElement.connection_pool.with_connection do |connection|
        # A savepoint would not make a newly planned task visible to another
        # executor. The handoff must run outside any caller-owned transaction.
        fail 'Applicability dispatch must run outside a transaction' if connection.transaction_open?

        locked = lock_query(connection, "SELECT pg_try_advisory_lock(#{DISPATCH_LOCK})")
        next 0 unless locked

        begin
          host_ids, queue_ids = HostQueueElement.transaction do
            pending = HostQueueElement.where('id <= ?', cutoff)
            ids = pending.group(:host_id).order(Arel.sql('MIN(id)')).limit(batch_size).pluck(:host_id)
            [ids, pending.where(host_id: ids).pluck(:id)]
          end
          next 0 if host_ids.empty?

          yield host_ids
          HostQueueElement.transaction { HostQueueElement.where(id: queue_ids).delete_all }
          host_ids.length
        ensure
          # Keep the same checked-out session until the handoff is finished.
          lock_query(connection, "SELECT pg_advisory_unlock(#{DISPATCH_LOCK})")
        end
      end
    end
    private_class_method :dispatch_batch

    # Distinct tasks for one host can overlap after a new upload or recovery.
    # Serialize their calculations, without locking profile ingestion itself.
    def self.with_host_lock(host_id)
      HostQueueElement.transaction(requires_new: true) do
        lock_query(HostQueueElement.connection, "SELECT pg_advisory_xact_lock(#{HOST_LOCK}, #{Integer(host_id)})")
        yield
      end
    end

    # These SELECTs change PostgreSQL session state; a cached result would
    # silently skip acquiring or releasing the actual lock.
    def self.lock_query(connection, sql)
      connection.uncached { connection.select_value(sql) }
    end
    private_class_method :lock_query
  end
end
