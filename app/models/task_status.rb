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

class TaskStatus < ActiveRecord::Base
  serialize :progress
  serialize :parameters, Hash
  class Status
    WAITING = :waiting
    RUNNING = :running
    ERROR = :error
    FINISHED = :finished
    CANCELED = :canceled
    TIMED_OUT = :timed_out
  end

  include Authorization
  belongs_to :organization
  belongs_to :user
  before_save :setup_task_type

  before_save do |status|
    unless status.user
      status.user = User.current
    end
  end

  def initialize(attrs = nil)
    unless attrs.nil?
      # only keep keys for which we have db columns
      attrs = attrs.reject do |k, v|
        !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
      end
    end

    super(attrs)
  end


  def refresh
    self
  end


  def refresh_pulp
    PulpTaskStatus.refresh(self)
  end

  def pending?
    self.state.to_s == "waiting" || self.state.to_s == "error"
  end

  protected
  def setup_task_type
    unless self.task_type
      self.task_type = self.class().name
    end
  end

end
