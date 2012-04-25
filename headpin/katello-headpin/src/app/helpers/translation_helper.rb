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

module TranslationHelper
  def relative_time_in_words(time)
    _("%s ago") % time_ago_in_words(time)
  end

  def months
    t('date.month_names')
  end

  def month(i)
    return '' unless i
    i = i.to_time.month if i.respond_to? :to_time
    months[i]
  end
end
