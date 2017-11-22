class RemoveHiddenColumnFromUser < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :hidden
  end

  def down
    add_column :users, :hidden, :boolean, :default => false, :null => false
  end
end
