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

require 'content_node_capability'

class NodeCapability < ActiveRecord::Base

  belongs_to :node

  serialize :configuration, Hash

  validates_presence_of :node_id

  def self.class_for(type)
    self.subclasses.each do |subclass|
      return subclass if type == subclass::TYPE
    end
    nil
  end

  def update_environments
    raise "update_environments not implemented"
  end

  def sync(options = {})
    raise "Sync Not implemented"
  end

  def validate_configuration
    raise "Empty capability not supported"
  end

end
