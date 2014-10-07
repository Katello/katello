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
  class ContentViewComponent < Katello::Model
    self.include_root_in_json = false

    belongs_to :content_view, :class_name => "Katello::ContentView",
      :inverse_of => :content_view_components
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion",
      :inverse_of => :content_view_components

    validates_lengths_from_database
    validates :content_view_version_id, :uniqueness => {:scope => :content_view_id}
    validate :content_view_types

    private

    def content_view_types
      if !content_view.composite?
        errors.add(:base, _("Cannot add component versions to a non-composite content view"))
      end
      if content_view_version.content_view.composite?
        errors.add(:base, _("Cannot add composite versions to a composite content view"))
      end
      if content_view_version.default?
        errors.add(:base, _("Cannot add default content view to composite content view"))
      end
    end
  end
end
