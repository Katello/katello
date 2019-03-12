class AddModularColumnToRpms < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_rpms, :modular, :boolean, :default => false
  end
end
