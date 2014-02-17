class RemoveChangeset < ActiveRecord::Migration
  def up
    drop_table "katello_changeset_content_views"
    drop_table "katello_changeset_users"
    drop_table "katello_changesets"
  end

  def down
    #nothing to do
  end
end
