class CreateNotices < ActiveRecord::Migration
  def self.up
    # These are notice messages
    create_table :notices do |t|
      t.string  :text,    :null => false, :limit => 1024
      t.text  :details
      t.boolean :global,  :null => false, :default => false
      t.string  :level,   :null => false
      t.timestamps
    end
    # Global messages have to be acknowledged by every user individually
    create_table :user_notices do |t|
      t.references :user
      t.references :notice
      t.boolean :viewed, :null => false, :default => false
    end
  end

  def self.down
    drop_table :user_notices
    drop_table :notices
  end
end
