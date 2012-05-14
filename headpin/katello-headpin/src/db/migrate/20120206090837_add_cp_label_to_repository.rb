class AddCpLabelToRepository < ActiveRecord::Migration
  def self.up
    #add_column :repositories, :cp_label, :string, :null => false
    add_column :repositories, :cp_label, :string
    add_index :repositories, :cp_label
  end

  def self.down
    remove_index :repositories, :cp_label
    remove_column :repositories, :cp_label
  end
end
