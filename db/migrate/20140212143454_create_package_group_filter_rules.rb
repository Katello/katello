class CreatePackageGroupFilterRules < ActiveRecord::Migration
  def change
    create_table :katello_package_group_filter_rules do |t|
      t.references :filter
      t.string :name

      t.timestamps
    end
  end
end
