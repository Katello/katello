class AddRegistryURLToKatelloFlatpakRemotes < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_flatpak_remotes, :registry_url, :string
  end
end
