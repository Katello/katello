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
    @execution_plan ||= Orchestrate.world.persistence.load_execution_plan(self.uuid)
  end

  def actions
    run_actions.map do |action|
      { action: action.action_class.name,
        input:  action.task_input,
        output: action.task_output }
    end
  end

  # returns true if the task is running or waiting to be run
  def pending
    dynflow_execution_plan.state != 'stopped'
  end

  private

  def run_actions
    @run_actions ||= execution_plan.run_flow.all_step_ids.map do |step_id|
      execution_plan.steps[step_id].load_action
    end
  end

end
