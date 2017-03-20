class RemoveCvPermissionForEnv < ActiveRecord::Migration
  def change
    Permission.find_by(:name => "promote_or_remove_content_views_to_environments").destroy!
  end
end
