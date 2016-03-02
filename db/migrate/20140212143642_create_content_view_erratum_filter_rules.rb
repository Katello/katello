class CreateContentViewErratumFilterRules < ActiveRecord::Migration
  def change
    create_table :katello_content_view_erratum_filter_rules do |t|
      t.references :content_view_filter
      t.string :errata_id, :limit => 255
      t.string :start_date, :limit => 255
      t.string :end_date, :limit => 255
      t.string :types, :limit => 255

      t.timestamps
    end
  end
end
