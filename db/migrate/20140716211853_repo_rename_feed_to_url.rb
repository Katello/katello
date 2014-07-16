class RepoRenameFeedToUrl < ActiveRecord::Migration
  def up
    rename_column :katello_repositories, :feed, :url
  end

  def down
    rename_column :katello_repositories, :url, :feed
  end
end
