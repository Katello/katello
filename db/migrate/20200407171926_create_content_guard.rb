class CreateContentGuard < ActiveRecord::Migration[5.2]
  def change
    create_table :katello_content_guards do |t|
      t.string :pulp_href, :null => false
      t.string :name, :null => false, :unique => true
    end

    add_column :katello_distribution_references, :content_guard_href, :string
  end
end
