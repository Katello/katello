class ChangesetDistributions < ActiveRecord::Migration
  def self.up
    create_table :changeset_distributions do |t|
       t.integer :changeset_id
       t.string :distribution_id
       t.string :display_name
       t.references :product, :null=>false
    end
  end

  def self.down
    drop_table :changeset_distributions
  end
end
