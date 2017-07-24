module Katello
  class ContentViewRepository < Katello::Model
    ALLOWED_REPOSITORY_TYPES = [Repository::YUM_TYPE,
                                Repository::DOCKER_TYPE,
                                Repository::OSTREE_TYPE,
                                Repository::FILE_TYPE,
                                Repository::DEB_TYPE
                               ].freeze

    belongs_to :content_view, :inverse_of => :content_view_repositories,
                              :class_name => "Katello::ContentView"
    belongs_to :repository, :inverse_of => :content_view_repositories,
                            :class_name => "Katello::Repository"

    validates_lengths_from_database
    validates :repository_id, :uniqueness => {:scope => :content_view_id}
    validate :content_view_composite
    validate :ensure_repository_type
    validate :check_repo_membership

    private

    def content_view_composite
      if content_view.composite?
        errors.add(:base, _("Cannot add repositories to a composite content view"))
      end
    end

    def ensure_repository_type
      unless ALLOWED_REPOSITORY_TYPES.include?(repository.content_type)
        errors.add(:base, _("Cannot add %s repositories to a content view.") % repository.content_type)
      end
    end

    def check_repo_membership
      unless self.content_view.organization == self.repository.product.organization
        errors.add(:base, _("Cannot add a repository from an Organization other than %s.") % self.content_view.organization.name)
      end

      unless self.repository.content_view.default?
        errors.add(:base, _("Repositories from published Content Views are not allowed."))
      end
    end
  end
end
