class RemoveDuplicateKatelloPoolsIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :katello_pools, name: 'index_pools_on_cp_id'
  end
end
