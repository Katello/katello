class AddOrganizationExtensions < ActiveRecord::Migration
  def change
    add_column :taxonomies, :label, :string
    add_column :taxonomies, :description, :text

    add_index(:taxonomies, :label, :unique=>true)
  end
end

