class AddEnvironmentPriors < ActiveRecord::Migration
  def self.up
    create_table :environment_priors, :id => false do |t|
      t.references :environment
      t.integer :prior_id, :null => false
    end
  end

  def self.down
    drop_table :environment_priors
  end
end
