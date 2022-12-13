class RemoveDrpmFromIgnorableContent < ActiveRecord::Migration[6.0]
  def up
    Katello::RootRepository.select { |r| !r&.ignorable_content&.blank? }.each do |root|
      if root&.ignorable_content&.include?("srpm")
        root.ignorable_content = ["srpm"]
      else
        root.ignorable_content = []
      end
      root.save!
    end
  end

  def down
    #noop
  end
end
