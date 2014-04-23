class AllowNullContentViewToActivationKey < ActiveRecord::Migration
  def up
    change_column :katello_activation_keys, :environment_id, :integer, :null => true
  end

  def down
    change_column :katello_activation_keys, :environment_id, :integer, :null => false
  end
end
