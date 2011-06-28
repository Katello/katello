class SystemTemplateErrata < ActiveRecord::Migration
  def self.up
    create_table :system_template_errata do |t|
       t.integer :system_template_id, :null => false
       t.string :erratum_id, :null => false
    end
  end

  def self.down
    drop_table :system_templates_errata
  end
end
