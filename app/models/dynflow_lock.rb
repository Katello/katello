class DynflowLock < ActiveRecord::Base
  attr_accessible :resource_id, :resource_type, :uuid

  belongs_to :dynflow_execution_plan,
             class_name: 'DynflowExecutionPlan',
             foreign_key: :uuid
  belongs_to :dynflow_task, foreign_key: :uuid
  belongs_to :resource, polymorphic: true

  scope :active, -> do
    includes(:dynflow_execution_plan)
    .where('dynflow_execution_plans.state != ?', :stopped)
  end

  scope :inactive, -> do
    includes(:dynflow_execution_plan)
    .where('dynflow_execution_plans.state = ?', :stopped)
  end

  scope :for_model, -> model do
    where(resource_id: model.id, resource_type: model.class.name)
  end

  def self.active_lock(model)
    active.for_model(model).first
  end

  def self.lock!(uuid, model)
    if model.new_record?
      raise "Model #{model} has to be saved before locking it"
    end
    if lock = DynflowLock.active_lock(model)
      raise "Model #{model} has already been locked by task #{lock.uuid}"
    end

    DynflowLock.create!(:uuid => uuid) do |new_lock|
      new_lock.resource = model
    end
  end


end
