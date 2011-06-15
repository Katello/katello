#
# Copyright 2011 Red Hat, Inc.
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
class SearchFavorite < ActiveRecord::Base
  include SearchHelper

  belongs_to :user
  validate :max_favorites

  def max_favorites
    if new_record?
      path = self.attributes["path"]
      if count_favorites(path) >= max_search_favorites
        errors.add(:base, _("Only #{max_search_favorites} favorites may be created."))
      end
    end
  end

  def count_favorites path
    count = ::SearchFavorite.where(:user_id => self.user_id, :path => path).count(:id)
  end

end
