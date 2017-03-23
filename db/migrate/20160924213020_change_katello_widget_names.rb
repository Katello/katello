class ChangeKatelloWidgetNames < ActiveRecord::Migration
  class Widget < ApplicationRecord
    self.table_name = "widgets"
  end

  def up
    Widget.where(:name => 'Errata Widget').update_all(:name => 'Latest Errata')
    Widget.where(:name => 'Content Views Widget').update_all(:name => 'Content Views')
    Widget.where(:name => 'Content Host Subscription Status Widget').update_all(:name => 'Host Subscription Status')
    Widget.where(:name => 'Subscription Status Widget').update_all(:name => 'Subscription Status')
    Widget.where(:name => 'Host Collection Widget').update_all(:name => 'Host Collections')
  end

  def down
    Widget.where(:name => 'Latest Errata').update_all(:name => 'Errata Widget')
    Widget.where(:name => 'Content Views').update_all(:name => 'Content Views Widget')
    Widget.where(:name => 'Host Subscription Status').update_all(:name => 'Content Host Subscription Status Widget')
    Widget.where(:name => 'Subscription Status Widget').update_all(:name => 'Subscription Status')
    Widget.where(:name => 'Host Collections').update_all(:name => 'Host Collection Widget')
  end
end
