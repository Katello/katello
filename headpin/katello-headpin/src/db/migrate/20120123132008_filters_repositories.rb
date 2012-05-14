class FiltersRepositories < ActiveRecord::Migration
  def self.up
    create_table :filters_repositories, :id => false do |t|
       t.integer :filter_id
       t.integer :repository_id
    end
  end

  def self.down
    drop_table :filters_repositories
  end
end
