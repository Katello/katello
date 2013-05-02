class RemoveFilters < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.tables.include?("filters")
      remove_index :filters_products, :column=>:filter_id
      remove_index :filters_products, :column=>:product_id

      drop_table "filters_products"

      remove_index :filters_repositories, :column=>:filter_id
      remove_index :filters_repositories, :column=>:repository_id

      drop_table "filters_repositories"

      remove_index :filters, :column=>:pulp_id
      remove_index :filters, :column=>:organization_id
      remove_index(:filters, :column => [:name, :organization_id])

      drop_table :filters
    end
  end

  def self.down
    #permanent action cannot be rolled back
  end
end
