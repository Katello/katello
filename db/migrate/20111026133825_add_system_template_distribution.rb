class AddSystemTemplateDistribution < ActiveRecord::Migration
  def self.up
    create_table :system_template_distributions do |t|
      t.integer :system_template_id, :null => false
      t.string :distribution_pulp_id, :null => false
    end
    add_index :system_template_distributions, :system_template_id
  end

  def self.down
    drop_table :system_template_distributions
  end
end
