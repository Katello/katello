module Katello
  class ContentViewRepository < Katello::Model
    ALLOWED_REPOSITORY_TYPES = [Repository::YUM_TYPE,
                                Repository::DOCKER_TYPE,
                                Repository::OSTREE_TYPE,
                                Repository::FILE_TYPE
                               ].freeze

    belongs_to :content_view, :inverse_of => :content_view_repositories,
                              :class_name => "Katello::ContentView"
    belongs_to :repository, :inverse_of => :content_view_repositories,
                            :class_name => "Katello::Repository"

    validates_lengths_from_database
    validates :repository_id, :uniqueness => {:scope => :content_view_id}
    validate :ensure_repository_type

    private

    def ensure_repository_type
      unless ALLOWED_REPOSITORY_TYPES.include?(repository.content_type)
        errors.add(:base, _("Cannot add %s repositories to a content view.") % repository.content_type)
      end
    end
  end
end
