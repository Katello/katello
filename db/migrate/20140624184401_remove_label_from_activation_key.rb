class RemoveLabelFromActivationKey < ActiveRecord::Migration
  def up
    remove_column :katello_activation_keys, :label
  end

  def down
    add_column :katello_activation_keys, :label, :string
  end
end
