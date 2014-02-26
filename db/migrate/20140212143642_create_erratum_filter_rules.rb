class CreateErratumFilterRules < ActiveRecord::Migration
  def change
    create_table :katello_erratum_filter_rules do |t|
      t.references :filter
      t.string :errata_id
      t.string :start_date
      t.string :end_date
      t.string :types

      t.timestamps
    end
  end
end
