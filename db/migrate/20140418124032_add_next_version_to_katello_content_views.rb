class AddNextVersionToKatelloContentViews < ActiveRecord::Migration
  def up
    add_column :katello_content_views, :next_version, :int, :null => false, :default => 1

    Katello::ContentView.reset_column_information

    # update the next version field based on max version
    Katello::ContentView.all.each do |view|
      view.update_attribute(:next_version, view.versions.maximum(:version) + 1) if view.versions.any?
    end
  end

  def down
    remove_column :katello_content_views, :next_version
  end
end
