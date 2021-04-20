class AddPulp3HrefsToContentTypesDeb < ActiveRecord::Migration[6.0]
  def change
    add_column Katello::Deb.table_name, :migrated_pulp3_href, :string, :default => nil, :null => true
  end
end
