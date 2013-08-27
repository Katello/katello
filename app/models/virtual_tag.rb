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
#


# This class is a "fake" model Tag. It is returned by model objects to the
# view layer to present possible tags which can be assigned to permissions.
class VirtualTag
  attr_accessor :name, :display_name

  def initialize(name, display_name)
    raise ArgumentError, "Name cannot be nil or empty" if name.nil? || name == ''
    raise ArgumentError, "Display name cannot be nil or empty" if display_name.nil? || display_name == ''
    self.name = name
    self.display_name = display_name
  end
end
