class CreateHelpTips < ActiveRecord::Migration
  def self.up
    create_table :help_tips do |t|
      t.string :key
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :help_tips
  end
end
