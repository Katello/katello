class DynflowTask < ActiveRecord::Base

  self.primary_key = :uuid

  attr_accessible :action, :organization_id, :user_id, :uuid

  belongs_to :dynflow_execution_plan,
             class_name: 'DynflowExecutionPlan',
             foreign_key: :uuid
  has_many :dynflow_locks, foreign_key: :uuid

end
