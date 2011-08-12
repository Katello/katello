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

module RolesHelper
  include BreadcrumbHelper::RolesBreadcrumbs

  def closed_id(f)
    "closed_#{perm_id(f)}"
  end

  def opened_id(f)
    "opened_#{perm_id(f)}"
  end

  def perm_id(f)
    f = f.object unless Permission === f
    return f.object_id if f.new_record?
    f.id
  end

  def get_scopes(f)
    return Tag.tags_for(resource_types.first[0]) || [] if f.object.new_record?
    Tag.tags_for(f.object.resource_type.name) || []
  end

  def get_verbs(f)
    if f.object.new_record?
      verbs =  Verb.verbs_for(resource_types.first[0]) || {}
      verbs = verbs.collect {|name, display| [name, display]}
      verbs.sort! {|a,b| a[1] <=> b[1]}
      return verbs
    end
    Verb.verbs_for(f.object.resource_type.name) || []
  end

end
