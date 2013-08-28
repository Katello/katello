class RepositoryAddFeed < ActiveRecord::Migration
  def self.up
    add_column :repositories, :feed, :string
    Repository.reset_column_information
    User.current = User.hidden.first
    Repository.all.each do |repo|
      if repo.environment.library? && !repo.importers.empty?
        repo.feed = repo.importers[0][:config][:feed_url]
        repo.save!
      end
    end
  end

  def self.down
    drop_column :repositories, :feed
  end
end
