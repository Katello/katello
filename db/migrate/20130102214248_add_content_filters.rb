class AddContentFilters < ActiveRecord::Migration
  def self.up
    create_table :filters do |t|
      t.references :content_view_definition
      t.string :name, :null => false
      t.timestamps
    end

    create_table :filter_rules do |t|
      t.string :type
      t.text :parameters
      t.references :filter, :null => false
      t.boolean :inclusion, :default=> true
      t.timestamps
    end

    create_table :filters_repositories, :id => false do |t|
      t.references :filter
      t.references :repository
    end

    add_index :filters, :content_view_definition_id
    add_index :filter_rules, :filter_id
    add_index(:filters, [:name, :content_view_definition_id], :unique => true)

    add_index :filters_repositories, :filter_id
    add_index :filters_repositories, :repository_id

    add_index(:filters_repositories, [:filter_id, :repository_id], :unique => true)

  end

  def self.down
    remove_index :filters, :column => :content_view_definition_id
    remove_index(:filters, :column => [:name, :content_view_definition_id])

    remove_index :filter_rules, :column => :filter_id

    remove_index :filters_repositories, :column => :filter_id
    remove_index :filters_repositories, :column => :repository_id
    remove_index(:filters_repositories, :column =>[:filter_id, :repository_id])

    drop_table :filters_repositories
    drop_table :filter_rules
    drop_table :filters
  end
end
