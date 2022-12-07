class UpdateIgnoreSrpmToFalseForMirrorComplete < ActiveRecord::Migration[6.1]
  def change
    Katello::RootRepository.yum_type.where(mirroring_policy: 'mirror_complete', ignorable_content: ['srpm']).update_all(ignorable_content: [])
  end
end
