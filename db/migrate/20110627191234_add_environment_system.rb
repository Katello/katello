class AddEnvironmentSystem < ActiveRecord::Migration
  def self.up
    change_table :systems do |t|
      t.references :environment
    end
  end

  def self.down
    change_table :systems do |t|
      t.remove :environment_id
    end
  end
end
