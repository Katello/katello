#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class CustomInfo < ActiveRecord::Base
  acts_as_reportable

  attr_accessible :keyname, :value

  belongs_to :informable, :polymorphic => true

  validates :keyname, :presence => true
  validates :value, :presence => true
  validates_uniqueness_of :keyname, :scope => [:value, :informable_type, :informable_id], :message => "already exists for this object"

  validates :informable_id, :presence => true
  validates :informable_type, :presence => true
end
