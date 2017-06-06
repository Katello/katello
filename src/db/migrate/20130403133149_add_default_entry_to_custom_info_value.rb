class AddDefaultEntryToCustomInfoValue < ActiveRecord::Migration

  def self.up
    change_column :custom_info, :value, :string, :default => ""
    CustomInfo.all.each do |ci|
      ci.value ||= ""
      ci.save!
    end
  end

  def self.down
    change_column :custom_info, :value, :string
  end
end
