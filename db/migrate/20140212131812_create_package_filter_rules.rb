class CreatePackageFilterRules < ActiveRecord::Migration
  def change
    create_table :katello_package_filter_rules do |t|
      t.references :filter
      t.string :name
      t.string :version
      t.string :min_version
      t.string :max_version

      t.timestamps
    end
  end
end
