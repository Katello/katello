class AddRepositoryMirroringPolicy < ActiveRecord::Migration[6.0]
  def up
    add_column :katello_root_repositories, :mirroring_policy, :string

    #RH repos can handle COMPLETE always, but custom cannot, so lets migrate custom to 'MIRRORING_POLICY_CONTENT'
    Katello::RootRepository.where(:content_type => 'yum').redhat.where(:mirror_on_sync => true).update_all(:mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_COMPLETE)
    Katello::RootRepository.where(:content_type => 'yum').custom.where(:mirror_on_sync => true).update_all(:mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_CONTENT)

    Katello::RootRepository.where.not(:content_type => 'yum').where(:mirror_on_sync => true).update_all(:mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_CONTENT)
    Katello::RootRepository.where(:mirror_on_sync => false).update_all(:mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_ADDITIVE)

    change_column :katello_root_repositories, :mirroring_policy, :string, :null => false
    remove_column :katello_root_repositories, :mirror_on_sync
  end

  def down
    add_column :katello_root_repositories, :mirror_on_sync, :boolean, default: true, null: true

    Katello::RootRepository.where(:mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_COMPLETE).update_all(:mirror_on_sync => true)
    Katello::RootRepository.where(:mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_CONTENT).update_all(:mirror_on_sync => true)
    Katello::RootRepository.where(:mirroring_policy => ::Katello::RootRepository::MIRRORING_POLICY_ADDITIVE).update_all(:mirror_on_sync => false)
    change_column :katello_root_repositories, :mirror_on_sync, :boolean, :null => false, :default => true

    remove_column :katello_root_repositories, :mirroring_policy
  end
end
