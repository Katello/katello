class ChangeErrataTimestampsToDates < ActiveRecord::Migration
  def up
    change_column(:katello_errata, :issued, :date)
    change_column(:katello_errata, :updated, :date)
    add_index(:katello_errata, :issued)
    add_index(:katello_errata, :updated)
  end

  def down
    change_column(:katello_errata, :issued, :timestamp)
    change_column(:katello_errata, :updated, :timestamp)
    remove_index(:katello_errata, :issued)
    remove_index(:katello_errata, :updated)
  end
end
