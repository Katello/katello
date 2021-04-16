class AddCreatedInKatelloToTaxonomy < ActiveRecord::Migration[6.0]
  def up
    add_column :taxonomies, :created_in_katello, :bool, default: false, null: false
  end

  def down
    remove_column :taxonomies, :created_in_katello
  end
end
