class AddMissingRpmsEvrIndex < ActiveRecord::Migration[7.0]
  def up
    # Re-add the katello_rpms EVR index dropped erroneously by 20240924161240.
    unless index_exists?(:katello_rpms, [:name, :arch, :evr])
      add_index :katello_rpms, [:name, :arch, :evr]
    end
  end

  def down
    if index_exists?(:katello_rpms, [:name, :arch, :evr])
      remove_index :katello_rpms, [:name, :arch, :evr]
    end
  end
end
