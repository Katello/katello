class RemoveHostTaskWorkerPoolSetting < ActiveRecord::Migration[7.0]
  def up
    ::Setting.where(name: 'host_tasks_workers_pool_size').delete_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
