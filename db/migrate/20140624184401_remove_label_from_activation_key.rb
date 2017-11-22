class RemoveLabelFromActivationKey < ActiveRecord::Migration[4.2]
  def up
    remove_column :katello_activation_keys, :label
  end

  def down
    add_column :katello_activation_keys, :label, :string, :limit => 255
  end
end
