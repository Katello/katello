class CustomInfoAddDefaultColumn < ActiveRecord::Migration
  def up
    add_column :custom_info, :org_default, :boolean, :default => false
  end

  def down
    remove_column :custom_info, :org_default
  end
end
