class RemoveKatelloDefaultPxegrub < ActiveRecord::Migration[7.0]
  def up
    ::Setting.where(name: 'katello_default_PXEGrub').delete_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
