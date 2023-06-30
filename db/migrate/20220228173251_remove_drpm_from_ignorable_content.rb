class RemoveDrpmFromIgnorableContent < ActiveRecord::Migration[6.0]
  def up
    Katello::RootRepository.select { |r| !r&.ignorable_content&.blank? }.each do |root|
      if root&.ignorable_content&.include?("srpm")
        root.ignorable_content = ["srpm"]
      else
        root.ignorable_content = []
      end
      root.checksum_type = nil if root.download_policy == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
      root.save!
    end
  end

  def down
    #noop
  end
end
