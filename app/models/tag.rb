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

class Tag
  def self.formatted(resource_type_name, tag_id)
    model_klass = ResourceType::TYPES[resource_type_name][:model]

    if model_klass
      tags = model_klass.tags(tag_id) rescue []
      return tags[0] if tags && !tags.empty?
    else
      raise "Unrecognized model #{model_klass}"
    end

    tag_id
  end

  def self.tags_for(resource_type_name, organization_id)
    model_klass = ResourceType::TYPES[resource_type_name][:model]

    if model_klass
      tag_list = model_klass.list_tags(organization_id) if model_klass.respond_to? :list_tags
      tag_list ||= []
      return tag_list
    else
      raise "Unrecognized model #{model_klass}"
    end

  end

end
