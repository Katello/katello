module Katello
  class FlatpakRemote < Katello::Model
    has_many :remote_repositories, dependent: :destroy, class_name: 'Katello::FlatpakRemoteRepository'
    has_many :remote_repository_manifests, through: :remote_repositories, source: :remote_repository_manifests
    belongs_to :organization, inverse_of: :flatpak_remotes

    validates :name, presence: true
    validates :url, presence: true
    validates :organization_id, presence: true
  end
end
