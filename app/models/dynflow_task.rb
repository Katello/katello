class DynflowTask < ActiveRecord::Base

  self.primary_key = :uuid

  attr_accessible :action, :organization_id, :user_id, :uuid

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

end
