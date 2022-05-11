class AddLastRefreshedToKatelloAlternateContentSources < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_alternate_content_sources, :last_refreshed, :datetime
  end
end
