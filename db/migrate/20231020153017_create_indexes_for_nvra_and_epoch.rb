class CreateIndexesForNvraAndEpoch < ActiveRecord::Migration[6.1]
  def change
    add_index :katello_installed_packages, :nvra
    add_index :katello_installed_packages, [:nvra, :epoch]
  end
end
