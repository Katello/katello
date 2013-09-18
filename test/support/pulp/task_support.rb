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

class PulpTaskStatus
  def self.any_task_running(async_tasks)
    return false
  end
end

module ConsumerSupport

  @consumer = nil

  def self.consumer_id
    @consumer.id
  end
end

module TaskSupport

  def self.wait_on_tasks(task_list, options={})
    ignore_exception = options.fetch(:ignore_exception, false)

    task_list = [task_list] if !task_list.is_a? Array
    PulpTaskStatus.wait_for_tasks(task_list)

  rescue RuntimeError => e
    if !ignore_exception
      puts e
      puts e.backtrace
    end
  rescue => e
    puts e
    puts e.backtrace
  end

end
