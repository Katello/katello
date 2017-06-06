class RenameLockerToLibrary < ActiveRecord::Migration
  class Environment < ActiveRecord::Base
  end

  def self.up
    rename_column :environments,  :locker, :library
    Environment.update_all({:name => 'Library'}, {:name => 'Locker'})
  end

  def self.down
    rename_column :environments, :library, :locker
    Environment.update_all({:name => 'Locker'}, {:name => 'Library'})
  end
end
