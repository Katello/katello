class RepositoryAddChecksumType < ActiveRecord::Migration
  def up
    add_column :katello_repositories, :checksum_type, :string, :null => true
  end

  def down
    remove_column :katello_repositories, :checksum_type
  end
end
