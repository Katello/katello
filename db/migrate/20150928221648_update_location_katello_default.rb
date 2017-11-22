class UpdateLocationKatelloDefault < ActiveRecord::Migration[4.2]
  def up
    change_column_default :taxonomies, :katello_default, false
  end

  def down
    change_column_default :taxonomies, :katello_default, true
  end
end
