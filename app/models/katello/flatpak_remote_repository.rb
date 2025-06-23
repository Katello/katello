module Katello
  class FlatpakRemoteRepository < Katello::Model
    include Ext::LabelFromName
    include ForemanTasks::Concerns::ActionSubject

    belongs_to :flatpak_remote, inverse_of: :remote_repositories
    has_many :remote_repository_manifests, dependent: :destroy, class_name: 'Katello::FlatpakRemoteRepositoryManifest'

    validates :flatpak_remote_id, presence: true
    validates :name, presence: true
    validates :label, presence: true

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :label, :complete_value => true
    scoped_search :on => :flatpak_remote_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :id, :complete_value => true

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

    def last_mirrored_task
      label = ::Actions::Katello::Flatpak::MirrorRemoteRepository.name
      type = ::Katello::FlatpakRemoteRepository.name
      ForemanTasks::Task.search_for("label = #{label} and resource_type = #{type} and resource_id = #{self.id}")
        .order("started_at desc")
        .first
    end

    def last_mirrored_status
      task = last_mirrored_task
      presenter = Katello::FlatpakRemoteMirrorStatusPresenter.new(self, task)
      presenter.mirror_progress.slice(:mirror_id, :result, :started_at, :last_mirror_words)
    end
  end
end
