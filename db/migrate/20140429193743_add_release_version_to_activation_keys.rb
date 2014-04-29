class AddReleaseVersionToActivationKeys < ActiveRecord::Migration
  def change
    add_column :katello_activation_keys, :release_version, :string
  end
end
