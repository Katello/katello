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

class ContentSearch::SearchUtils
  cattr_accessor :current_organization, :mode, :env_ids

  def self.search_mode
    case mode
      when "shared"
        :shared
      when "unique"
        :unique
      else
        :all
    end
  end

  def self.search_env_ids
    @@search_env_ids ||= if self.search_mode != :all
      KTEnvironment.content_readable(current_organization).where(:id => self.env_ids)
    end
  end

end
