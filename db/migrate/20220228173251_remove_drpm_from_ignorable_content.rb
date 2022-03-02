class RemoveDrpmFromIgnorableContent < ActiveRecord::Migration[6.0]
  def up
    Katello::RootRepository.select { |r| r&.ignorable_content&.include? "drpm" }.each do |root|
      root.ignorable_content = root.ignorable_content - ["drpm"]
      root.save!
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
