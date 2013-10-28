class DynflowExecutionPlan < ActiveRecord::Base

  self.table_name  = 'dynflow_execution_plans'
  self.primary_key = :uuid

  def self.create_or_update(*args)
    raise "Read only model - it's managed by Dynflow persistence layer"
  end
end
