#
# Copyright 2013 Red Hat, Inc.
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

    belongs_to :content_view, :inverse_of => :content_view_repositories,
      :class_name => "Katello::ContentView"
    belongs_to :repository, :inverse_of => :content_view_repositories,
      :class_name => "Katello::Repository"

    validates :repository_id, :uniqueness => {:scope => :content_view_id}
    validate :content_view_composite
    validate :non_puppet_repository

    private

    def content_view_composite
      if content_view.composite?
        errors.add(:base, _("Cannot add repositories to a composite content view"))
      end
    end

    def non_puppet_repository
      if repository.puppet?
        errors.add(:base, _("Cannot add puppet repositories to a content view"))
      end
    end
  end
end
