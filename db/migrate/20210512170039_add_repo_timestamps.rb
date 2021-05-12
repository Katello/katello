class AddRepoTimestamps < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_repositories, :last_contents_changed, :datetime, :default => Time.at(0).to_datetime
    add_column :katello_repositories, :last_applicability_regen, :datetime, :default => Time.at(0).to_datetime
  end
end
