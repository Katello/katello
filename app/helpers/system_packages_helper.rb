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

module SystemPackagesHelper

  def adding_package
    _("Adding Package...")
  end

  def updating_package
    _("Updating Package...")
  end

  def removing_package
    _("Removing Package...")
  end

  def adding_package_group
    _("Adding Package Group...")
  end

  def removing_package_group
    _("Removing Package Group...")
  end

  def get_status_string type
    case type
      when "package_install"
        adding_package
      when "package_update"
        updating_package
      when "package_remove"
        removing_package
      when "package_group_install"
        adding_package_group
      when "package_group_remove"
        removing_package_group
    end
  end

  def row_shading
    @shading = cycle("", "alt")
  end
end
