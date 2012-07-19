class AddingTypesToChangeset < ActiveRecord::Migration
  def self.up
    add_column :changesets, :action_type, :string, :default => Changeset::PROMOTION
    Changeset.reset_column_information
    Changeset.all.each do  |changeset|
      changeset.update_attributes!(:action_type => Changeset::PROMOTION)
    end
    execute("UPDATE changesets
             SET action_type = '#{Changeset::PROMOTION}'")

  end

  def self.down
    remove_column :changesets, :action_type
  end

end
