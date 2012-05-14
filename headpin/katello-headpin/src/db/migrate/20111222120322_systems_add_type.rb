class SystemsAddType < ActiveRecord::Migration
  def self.up
    add_column :systems, :type, :string, :default => "System"
  end

  def self.down
    remove_column :systems, :type
  end
end
