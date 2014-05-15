class UpdateProductsAddOrganization < ActiveRecord::Migration
  class Katello::Product < ActiveRecord::Base
    belongs_to :provider
    self.inheritance_column = nil
  end

  def up
    add_column :katello_products, :organization_id, :integer, :null => true

    Katello::Product.all.each do |product|
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
