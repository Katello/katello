module Katello
  class FlatpakRemote < Katello::Model
    include Authorization::FlatpakRemote
    include ForemanTasks::Concerns::ActionSubject

    has_many :remote_repositories, dependent: :destroy, class_name: 'Katello::FlatpakRemoteRepository'
    has_many :remote_repository_manifests, through: :remote_repositories, source: :remote_repository_manifests
    belongs_to :organization, inverse_of: :flatpak_remotes

    validates :name, presence: true
    validates :url, presence: true
    validates :organization_id, presence: true

    scope :seeded, -> { where(:seeded => true) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :url, :complete_value => true
    scoped_search :on => :seeded, :complete_value => true
  end
end
