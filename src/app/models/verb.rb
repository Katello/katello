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

class Verb < ActiveRecord::Base
  has_and_belongs_to_many :permission

  # alias for verb attribute
  def name
    verb
  end

  # used for user-friendly presentation of this record
  def display_name resource_type_name
    Verb.verbs_for(resource_type_name)[verb]
  end


  def self.verbs_for(resource_type_name)
    res_type = ResourceType::TYPES[resource_type_name]
    return res_type[:model].list_verbs if res_type && res_type[:model]
    {}
  end


end
