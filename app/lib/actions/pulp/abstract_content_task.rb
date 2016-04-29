module Actions
  module Pulp
    class AbstractContentTask < Pulp::AbstractAsyncTask
      def contents_changed?(tasks)
        if tasks.is_a?(Hash)
          # note: for syncs initiated by a sync plan, tasks is a hash input
          sync_task = tasks
        else
          sync_task = tasks.find { |task| (task['tags'] || []).include?('pulp:action:sync') }
        end

        if sync_task && sync_task['state'] == 'finished' && sync_task[:result]
          sync_task['result']['added_count'] > 0 || sync_task['result']['removed_count'] > 0 || sync_task['result']['updated_count'] > 0
        else
          true #if we can't figure it out, assume something changed
        end
      end

      def external_task=(tasks)
        output[:contents_changed] = contents_changed?(tasks)
        super
      end
    end
  end
end
