#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class ContentViewRepository < Katello::Model
    self.include_root_in_json = false

    ALLOWED_REPOSITORY_TYPES = [Repository::YUM_TYPE, Repository::DOCKER_TYPE]

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
