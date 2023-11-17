class CreateIndexesForNvraAndEpoch < ActiveRecord::Migration[6.1]
  def up
    if index_exists?(:katello_installed_packages, :nvra)
      remove_index :katello_installed_packages, :nvra
    end

    if index_exists?(:katello_installed_packages, [:nvra, :epoch])
      remove_index :katello_installed_packages, [:nvra, :epoch]
    end

    add_index :katello_installed_packages, :nvra
    add_index :katello_installed_packages, [:nvra, :epoch]
  end

  def down
    remove_index :katello_installed_packages, :nvra
    remove_index :katello_installed_packages, [:nvra, :epoch]
  end
end
