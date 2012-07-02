class AddRepositoryLibraryId < ActiveRecord::Migration
  def self.up
      change_table :repositories do |t|
          t.integer :library_instance_id, :null=>true
      end
  end

  def self.down
      remove_column :library_instance_id
  end
end
