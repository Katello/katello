class CreateSystemHostJoins < ActiveRecord::Migration
  def change
    create_table :katello_system_host_joins do |t|
      t.integer :host_id
      t.integer :system_id
      t.integer :kt_environment_id
      t.integer :content_view_id

      t.timestamps
    end
  end
end
