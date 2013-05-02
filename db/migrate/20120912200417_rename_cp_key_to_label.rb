class RenameCpKeyToLabel < ActiveRecord::Migration
  def self.up
    rename_column :organizations, :cp_key, :label
  end

  def self.down
    rename_column :organizations, :label, :cp_key
  end
end
