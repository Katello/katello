class ChangesetErrata < ActiveRecord::Migration
  def self.up
    create_table :changeset_errata do |t|
       t.integer :changeset_id
       t.string :errata_id
       t.string :display_name
    end
  end

  def self.down
    drop_table :changesets_errata
  end
end
