class CreateContentViewEnvironments < ActiveRecord::Migration
  def self.up
    create_table :content_view_environments do |t|
      t.string :name
      t.string :label, :null => false
      t.string :cp_id
      t.references :content_view
      t.timestamps
    end

    add_index :content_view_environments, :content_view_id
  end

  def self.down
    drop_table :content_view_environments
  end
end
