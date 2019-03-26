class RemoveVersionDateFromOstreeBranch < ActiveRecord::Migration[5.2]
  def change
    remove_column :katello_ostree_branches, :version_date, :timestamp
  end
end
