class CreateTasks < ActiveRecord::Migration
  def change
    create_table :katello_tasks, :id => false do |t|
      t.string :uuid, index: true
      t.string :action, index: true
    end
  end
end
