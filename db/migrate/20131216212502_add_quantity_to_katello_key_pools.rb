class AddQuantityToKatelloKeyPools < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_key_pools, :quantity, :integer
  end
end
