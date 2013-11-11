class DynflowTask < ActiveRecord::Base

  self.primary_key = :uuid

  attr_accessible :action, :organization_id, :user_id, :uuid

  belongs_to :user
  belongs_to :organization

  belongs_to :dynflow_execution_plan,
             class_name: 'DynflowExecutionPlan',
             foreign_key: :uuid

  has_many :dynflow_locks, foreign_key: :uuid

  scope :active, -> do
    joins(:dynflow_execution_plan)
    .where('dynflow_execution_plans.state != ?', :stopped)
  end

  scope :inactive, -> do
    joins(:dynflow_execution_plan)
    .where('dynflow_execution_plans.state = ?', :stopped)
  end

  def execution_plan
    Orchestrate.world.persistence.load_execution_plan(self.uuid)
  end

  # Searches for actions with +task_output+ method and collects the values.
  # It's used for getting data collected in the action into Rest API
  def outputs
    execution_plan = self.execution_plan
    run_actions    = execution_plan.run_flow.all_step_ids.map do |step_id|
      execution_plan.steps[step_id].load_action
    end
    actions_with_task_output = run_actions.select do |action|
      action.respond_to?(:task_output)
    end
    actions_with_task_output.map do |action|
      action.task_output.merge(action: action.action_class.name)
    end
  end

end
