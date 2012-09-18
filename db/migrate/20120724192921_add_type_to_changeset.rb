class AddTypeToChangeset < ActiveRecord::Migration
  def self.up
    add_column :changesets, :type, :string, :default => "PromotionChangeset"
    Changeset.reset_column_information
    execute("UPDATE changesets
             SET type = 'PromotionChangeset'")

  end

  def self.down
    remove_column :changesets, :type
  end
end
