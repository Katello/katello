class UpdateProductTypeAddDefault < ActiveRecord::Migration
  def self.up
    change_column :products, :type, :string, :default => "Product", :null => false
  end

  def self.down
    change_column :products, :type, :string, :default => nil, :null => true
  end
end
