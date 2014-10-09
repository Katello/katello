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
#
module Katello
  class SearchFavorite < Katello::Model
    self.include_root_in_json = false

    include SearchHelper

    belongs_to :user, :inverse_of => :search_favorites, :class_name => "::User"
    validates_lengths_from_database
    validate :max_favorites
    validates :params, :length => { :maximum => 255 }
    validates :path, :length => { :maximum => 255 }

    def max_favorites
      if new_record?
        path = self.attributes["path"]
        if count_favorites(path) >= max_search_favorites
          errors.add(:base, _("Only %s favorites may be created.") % max_search_favorites)
        end
      end
    end

    def count_favorites(path)
      SearchFavorite.where(:user_id => self.user_id, :path => path).count(:id)
    end

  end
end
