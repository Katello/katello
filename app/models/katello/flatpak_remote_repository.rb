module Katello
  class FlatpakRemoteRepository < Katello::Model
    include Ext::LabelFromName

    belongs_to :flatpak_remote, inverse_of: :remote_repositories
    has_many :remote_repository_manifests, dependent: :destroy, class_name: 'Katello::FlatpakRemoteRepositoryManifest'

    validates :flatpak_remote_id, presence: true
    validates :name, presence: true
    validates :label, presence: true

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :label, :complete_value => true
    scoped_search :on => :flatpak_remote_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

    alias_attribute :manifests, :remote_repository_manifests

    def self.readable
      where(flatpak_remote_id: FlatpakRemote.readable)
    end

    def manifest_dependencies
      FlatpakRemoteRepositoryManifest.where(flatpak_ref: self.manifests&.select(:runtime))
    end

    def repository_dependencies
      manifest_dependencies&.map(&:remote_repository)
    end
  end
end
