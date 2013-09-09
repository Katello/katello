class RepositoryAddRelativePath < ActiveRecord::Migration
  def self.up
    add_column :repositories, :relative_path, :string, :null => true
    Repository.reset_column_information
    User.current = User.hidden.first
    Repository.all.each do |repo|
      repo.relative_path = repo.distributors.first['config']['relative_url']
      repo.save!
    end
    change_column :repositories, :relative_path, :string, :null => false
  end

  def self.down
    remove_column :repositories, :relative_path
  end
end
