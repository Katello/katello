class AddReleaseVersionToActivationKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_activation_keys, :release_version, :string, :limit => 255
  end
end
