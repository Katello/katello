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

require 'util/model_util'

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :permission

  # used for user-friendly presentation of this record
  def display_name
    name
  end
  
  def formatted(resource_type_name)
    model_klass = ResourceType::TYPES[resource_type_name][:model]
        
    if model_klass
      tags = model_klass.tags(self.name) if model_klass.respond_to? :tags
      return tags[0]
    end
  end

  def self.tags_for(resource_type_name, organization_id) 
    model_klass = ResourceType::TYPES[resource_type_name][:model]
    
    if model_klass
      tag_list = model_klass.list_tags(organization_id) if model_klass.respond_to? :list_tags
      return tag_list
    else
      raise "Unrecognized model #{model_klass}"
    end

  end

end
