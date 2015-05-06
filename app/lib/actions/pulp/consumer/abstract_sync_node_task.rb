module Actions
  module Pulp
    module Consumer
      class AbstractSyncNodeTask <  ::Actions::Pulp::AbstractAsyncTask
        private

        def external_task=(external_task_data)
          external_task_data = [external_task_data] if external_task_data.is_a?(Hash)
          output[:pulp_tasks] = external_task_data.reject { |task| task['task_id'].nil? }

          output[:pulp_tasks].each do |pulp_task|
            if pulp_task[:result] && pulp_task[:result].key?(:succeeded) && pulp_task[:result][:succeeded] == false
              fail StandardError, _("Pulp task error.  Refer to task for more details.")
            end
          end
          super(external_task_data)
        end
      end
    end
  end
end
