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
  # The TaxonomyHelper contains extensions to the core application's
  # TaxonomyHelper
  module TaxonomyHelper
    def service_level_options
      options = @taxonomy.service_levels.collect { |level| [_("Service Level %s") % level, level] }
      options.unshift([_("No Service Level Preference"), ""])
      options
    end

    def service_level_selected
      @taxonomy.service_level.blank? ? "" : @taxonomy.service_level
    end
  end
end
