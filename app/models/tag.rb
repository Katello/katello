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

  def self.tags_for(resource_type_name, organization_id)

    # step 1 - try to load tags from our model classes
    model_klass = Katello::ModelUtils.table_to_class resource_type_name
    if model_klass
      return model_klass.list_tags(organization_id) if model_klass.respond_to? :list_tags
    end

    # step 2 - fetch information from the database
    Tag.select('DISTINCT(tags.name)').joins(:permission => :resource_type).where(:resource_types => { :name => resource_type_name })
  end

end
