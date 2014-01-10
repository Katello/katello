class AddQuantityToKatelloKeyPools < ActiveRecord::Migration
  def change
    add_column :katello_key_pools, :quantity, :integer
  end
end
