class AddNvreaToChangesetPackage < ActiveRecord::Migration
  class ChangesetPackage < ActiveRecord::Base
  end

  def self.up
    add_column :changeset_packages, :nvrea, :string
    ChangesetPackage.update_all "nvrea = display_name"
  end

  def self.down
    remove_column :changeset_packages, :nvrea
  end
end
