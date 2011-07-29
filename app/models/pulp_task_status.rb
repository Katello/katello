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

class PulpTaskStatus < TaskStatus

  def self.using_pulp_task(sync)
    self.new(
        :uuid => sync[:id],
        :state => sync[:state],
        :start_time => sync[:start_time],
        :finish_time => sync[:finish_time],
        :progress => sync[:progress],
        :result => sync[:result].nil? ? {:errors => [sync[:exception], sync[:traceback]]}.to_json : sync[:result]
    ) { |t| yield t if block_given? }
  end

  def refresh
    pulp_task = Pulp::Task.find(uuid)
    update_attributes!(
        :state => pulp_task[:state],
        :finish_time => pulp_task[:finish_time],
        :progress => pulp_task[:progress],
        :result => pulp_task[:result].nil? ? {:errors => [pulp_task[:exception], pulp_task[:traceback]]}.to_json : pulp_task[:result]
    )
    self
  end


end
