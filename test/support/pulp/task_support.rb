#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
class PulpTaskStatus
  def self.any_task_running_with_vcr(async_tasks)
    VCR.live? ? any_task_running_without_vcr(async_tasks) : false
  end

  class << self
    alias_method_chain :any_task_running, :vcr
  end
end
end

module Katello
module ConsumerSupport

  @consumer = nil

  def self.consumer_id
    @consumer.id
  end
end
end

module Katello
module TaskSupport

  def self.wait_on_tasks(task_list, options={})
    task_list = [task_list] unless task_list.is_a?(Array)
    ignore_exception = options.fetch(:ignore_exception, false)
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
end
