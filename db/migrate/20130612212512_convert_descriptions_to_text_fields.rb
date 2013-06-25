class ConvertDescriptionsToTextFields < ActiveRecord::Migration
  def up
    change_column :activation_keys, :description, :text
    change_column :changesets, :description, :text
    change_column :distributors, :description, :text
    change_column :environments, :description, :text
    change_column :organizations, :description, :text
    change_column :permissions, :description, :text
    change_column :products, :description, :text
    change_column :providers, :description, :text
    change_column :roles, :description, :text
    change_column :sync_plans, :description, :text
    change_column :system_groups, :description, :text
    change_column :systems, :description, :text
  end

  def down
    change_column :activation_keys, :description, :string
    change_column :changesets, :description, :string
    change_column :distributors, :description, :string
    change_column :environments, :description, :string
    change_column :organizations, :description, :string
    change_column :permissions, :description, :string
    change_column :products, :description, :string
    change_column :providers, :description, :string
    change_column :roles, :description, :string
    change_column :sync_plans, :description, :string
    change_column :system_groups, :description, :string
    change_column :systems, :description, :string
  end
end
