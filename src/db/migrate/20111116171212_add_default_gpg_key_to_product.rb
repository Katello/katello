class AddDefaultGpgKeyToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :gpg_key_id, :integer
  end

  def self.down
    remove_column :products, :gpg_key_id
  end

end
