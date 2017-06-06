class AddIndexesToKatelloRpms < ActiveRecord::Migration
  def change
    add_index "katello_repository_rpms", "rpm_id", :name => 'index_katello_repository_rpms_on_rpm_ids'
  end
end
