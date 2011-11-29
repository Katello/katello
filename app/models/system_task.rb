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

class SystemTask < ActiveRecord::Base

  TYPES = { 0 => :package_install,
            1 => :package_update,
            2 => :package_remove,
            3 => :package_group_install,
            4 => :package_group_update,
            5 => :package_group_remove}

  PACKAGE_INSTALL = SystemTask::TYPES.find{|key,value| value == :package_install}.first
  PACKAGE_UPDATE = SystemTask::TYPES.find{|key,value| value == :package_update}.first
  PACKAGE_REMOVE = SystemTask::TYPES.find{|key,value| value == :package_remove}.first
  PACKAGE_GROUP_INSTALL = SystemTask::TYPES.find{|key,value| value == :package_group_install}.first
  PACKAGE_GROUP_UPDATE = SystemTask::TYPES.find{|key,value| value == :package_group_update}.first
  PACKAGE_GROUP_REMOVE = SystemTask::TYPES.find{|key,value| value == :package_group_remove}.first

  belongs_to :system
  belongs_to :task_status

  has_many :package_tasks, :dependent => :destroy
end