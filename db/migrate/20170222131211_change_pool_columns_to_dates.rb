class ChangePoolColumnsToDates < ActiveRecord::Migration
  def up
    change_column(:katello_pools, :start_date, 'timestamp USING CAST(start_date AS timestamp without time zone)')
    change_column(:katello_pools, :end_date, 'timestamp USING CAST(end_date AS timestamp without time zone)')
    add_index(:katello_pools, :start_date)
    add_index(:katello_pools, :end_date)
  end

  def down
    change_column(:katello_pools, :start_date, :string, :limit => 255)
    change_column(:katello_pools, :end_date, :string, :limit => 255)
    remove_index(:katello_pools, :start_date)
    remove_index(:katello_pools, :end_date)
  end
end
