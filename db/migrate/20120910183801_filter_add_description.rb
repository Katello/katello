class FilterAddDescription < ActiveRecord::Migration
  def self.up
    add_column :filters, :description, :string
  end

  def self.down
    drop_column :filters, :description
  end
end
