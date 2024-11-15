module Katello
  class FlatpakRemoteRepositoryManifest < Katello::Model
    belongs_to :remote_repository,
               class_name: 'Katello::FlatpakRemoteRepository',
               foreign_key: 'flatpak_remote_repository_id',
               inverse_of: :remote_repository_manifests
    validates :flatpak_remote_repository_id, presence: true
    validates :name, presence: true

    def runtime_dependency
      FlatpakRemoteRepositoryManifest.where(flatpak_ref: self.runtime)
    end
  end
end
