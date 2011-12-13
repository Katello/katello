class UpdateProductsAddType < ActiveRecord::Migration
  def self.up
    add_column :products, :type, :string
  end

  def self.down
    remove_column :products, :type
  end
end
