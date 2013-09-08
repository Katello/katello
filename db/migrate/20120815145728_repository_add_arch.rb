class RepositoryAddArch < ActiveRecord::Migration
  def self.up
    add_column :repositories, :arch, :string, :null => false, :default => 'noarch'
    # TODO: Add migration for existing repos
  end

  def self.down
    remove_column :repositories, :arch
  end

end
