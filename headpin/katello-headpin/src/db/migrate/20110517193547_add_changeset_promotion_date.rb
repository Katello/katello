class AddChangesetPromotionDate < ActiveRecord::Migration
  def self.up
    add_column :changesets, :promotion_date, :datetime
  end

  def self.down
    drop_column :changesets, :promotion_date
  end
end
