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

  def input
    main_action.respond_to?(:task_input) && main_action.task_input
  end

  def output
    main_action.respond_to?(:task_output) && main_action.task_output
  end

  def username
    user && user.username
  end

  def humanized
    { action: main_action.respond_to?(:humanized_name) && main_action.humanized_name,
      input:  main_action.respond_to?(:humanized_input) && main_action.humanized_input,
      output: main_action.respond_to?(:humanized_output) && main_action.humanized_output }
  end

  def main_action
    return @main_action if @main_action
    main_action_id = execution_plan.root_plan_step.action_id
    @main_action = execution_plan.actions.find { |action| action.id == main_action_id }
  end

  # returns true if the task is running or waiting to be run
  def pending
    dynflow_execution_plan.state != 'stopped'
  end

end
