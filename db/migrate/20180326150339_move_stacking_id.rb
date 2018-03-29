class MoveStackingId < ActiveRecord::Migration[5.1]
  class StackSubscription < ApplicationRecord
    self.table_name = 'katello_subscriptions'
    has_many :pools, :class_name => "StackPool", :inverse_of => :subscription, :dependent => :destroy, :foreign_key => 'subscription_id'
  end

  class StackPool < ApplicationRecord
    self.table_name = 'katello_pools'
    belongs_to :subscription, :inverse_of => :pools, :class_name => "StackSubscription"
  end

  def up
    add_column :katello_pools, :stacking_id, :string

    StackSubscription.find_each do |sub|
      sub.pools.update_all(:stacking_id => sub.stacking_id)
    end

    remove_column :katello_subscriptions, :stacking_id
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
