class RemoveSystemGroupPulpId < ActiveRecord::Migration
  def up
    remove_column :system_groups, :pulp_id
  end

  def down
  end
end
