class UpdateLocationKatelloDefault < ActiveRecord::Migration
  def up
    change_column_default :taxonomies, :katello_default, false
  end

  def down
    change_column_default :taxonomies, :katello_default, true
  end
end
