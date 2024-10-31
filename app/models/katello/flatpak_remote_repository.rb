module Katello
  class FlatpakRemoteRepository < Katello::Model
    belongs_to :flatpak_remote, inverse_of: :remote_repositories
    has_many :remote_repository_manifests, dependent: :destroy, class_name: 'Katello::FlatpakRemoteRepositoryManifest'

    validates :flatpak_remote_id, presence: true
    validates :name, presence: true
    validates :label, presence: true

    alias_attribute :manifests, :remote_repository_manifests
  end
end
