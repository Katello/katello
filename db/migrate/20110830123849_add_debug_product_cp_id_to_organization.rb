class AddDebugProductCpIdToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :debug_product_cp_id, :string, :default => nil
  end

  def self.down
    remove_column :organizations, :debug_product_cp_id
  end
end
