class UpdateProductsAddOrganization < ActiveRecord::Migration[4.2]
  class FakeProduct < ApplicationRecord
    self.table_name = 'katello_products'
    belongs_to :provider
    self.inheritance_column = nil
  end

  def up
    add_column :katello_products, :organization_id, :integer, :null => true

    FakeProduct.all.each do |product|
      product.organization_id = product.provider.organization_id
      product.save!
    end

    change_column :katello_products, :organization_id, :integer, :null => false
    add_index :katello_products, :organization_id
  end

  def down
    remove_column :katello_products, :organization_id
  end
end
