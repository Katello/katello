class UpdateCompositeDefaultForContentView < ActiveRecord::Migration
  class Katello::ContentView
  end

  def up
    change_column_null(:katello_content_views, :composite, false, false)
    change_column_default(:katello_content_views, :composite, false)
  end

  def down
    change_column_null(:katello_content_views, :composite, nil)
    change_column_default(:katello_content_views, :composite, nil)
  end
end
