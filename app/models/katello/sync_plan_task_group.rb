module Katello
  class SyncPlanTaskGroup < ::ForemanTasks::TaskGroup
    has_one :sync_plan, :foreign_key => :task_group_id, :dependent => :nullify, :inverse_of => :task_group, :class_name => "Katello::SyncPlan"

    def resource_name
      N_('Sync Plan')
    end
  end
end
