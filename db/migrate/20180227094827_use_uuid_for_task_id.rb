class UseUuidForTaskId < ActiveRecord::Migration[5.0]
  # PostgreSQL has a special column type for storing UUIDs.
  # Using this type instead of generic string should lead to having
  #  smaller DB and possibly better overall performance.
  def up
    if on_postgresql?
      change_table :katello_content_view_histories do |t|
        t.change :task_id, :uuid, :using => 'task_id::uuid'
      end
    end
  end

  def down
    if on_postgresql?
      change_table :katello_content_view_histories do |t|
        t.change :task_id, :string, :null => true, :limit => 255
      end
    end
  end

  private

  def on_postgresql?
    ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  end
end
