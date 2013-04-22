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

require 'minitest_helper'


module TaskSupport

  def self.wait_on_tasks(task_list)
    task_list.each do |task|
      wait_on_task(task)
    end
  end

  def self.wait_on_task(task)
    VCR.use_cassette('task_support', :erb => true, :match_requests_on => [:path, :method, :body_json]) do
      while !(['finished', 'error', 'timed_out', 'canceled', 'reset', 'success'].include?(task['state'])) do
        task = PulpSyncStatus.pulp_task(Runcible::Resources::Task.poll(task['progress']["task_id"]))
        sleep_if_needed
      end
    end
  rescue Exception => e
  end

  def self.sleep_if_needed
    if VCR.configuration.default_cassette_options[:record] != :none
      sleep 0.5 # do not overload backend engines
    end
  end

end
