class AddLastIndexedToRepos < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_repositories, :last_indexed, :datetime, :default => Time.at(0).to_datetime
  end
end
