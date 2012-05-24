class AddUsageLimitToActivationKey < ActiveRecord::Migration
  def self.up
    add_column :activation_keys, :usage_limit, :integer
  end

  def self.down
    remove_column :activation_keys, :usage_limit
  end
end
