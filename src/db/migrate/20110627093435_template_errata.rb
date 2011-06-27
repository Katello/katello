class TemplateErrata < ActiveRecord::Migration
  def self.up
    create_table :template_errata do |t|
       t.integer :system_template_id
       t.string :errata_id
    end
  end

  def self.down
    drop_table :template_errata
  end
end
