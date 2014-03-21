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

# setup strong_parameters
require 'strong_parameters'

# role our own strong params integration so we can turn it off with a global
module Katello
  module ForbiddenAttributesProtection
    def sanitize_for_mass_assignment(*options)
      new_attributes = options.first
      if !new_attributes.respond_to?(:permitted?) || new_attributes.permitted? || !Thread.current[:strong_parameters]
        super
      else
        fail ActiveModel::ForbiddenAttributes, "Mass assignment called with an unpermitted hash"
      end
    end
  end
end
