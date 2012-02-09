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

class Task
  attr_reader :name, :status, :priority, :action, :timestamp

  def initialize opts
    @name      = opts[:name]
    @status    = opts[:status]
    @priority  = opts[:priority] || 0
    @action    = opts[:action]
    update_ts
  end

  def status=s
    if Queue::STATUS.include?(s)
      update_ts
      @status = s
    else
      raise "invalid STATE #{s}"
    end
  end

  def to_s
    "#{name}\t #{priority}\t #{status}\t #{action}"
  end

  private
  def update_ts
    @timestamp = Time.now
  end

  # sort based on priority
  def <=> other
    self.priority <=> other.priority
  end
end