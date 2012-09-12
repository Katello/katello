class FilterPackages < ActiveRecord::Migration
  def self.up
    create_table :filter_packages do |t|
       t.references :filter
       t.string :name, :null=>false
    end
  end

  def self.down
    drop_table :filter_packages
  end
end
