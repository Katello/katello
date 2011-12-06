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

  TYPES = { :package_install => {:class => SystemTask, :name => _("Package Install")},
            :package_update =>  {:class => SystemTask, :name => _("Package Update")},
            :package_remove => {:class => SystemTask, :name => _("Package Remove")},
            :package_group_install => {:class => SystemTask, :name => _("Package Group Install")},
            :package_group_update => {:class => SystemTask, :name => _("Package Group Update")},
            :package_group_remove => {:class => SystemTask, :name => _("Package Group Remove")},
  }.with_indifferent_access


  include Authorization
  belongs_to :organization

  before_save :setup_task_type



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


  def self.refresh(ids)
    type_map = {}
    ids.each do |i|
      task = TaskStatus.find(i)
      if task.task_type
        type_map[task.task_type] = [] unless type_map.has_key? task.task_type
        type_map[task.task_type] << i
      end
    end
    type_map.each_pair do |key, value|
      TYPES[key][:class].refresh(value)
    end
  end

  def refresh_pulp
    pulp_task = Pulp::Task.find(uuid)
    self.attributes = {
        :state => pulp_task[:state],
        :finish_time => pulp_task[:finish_time],
        :progress => pulp_task[:progress],
        :result => pulp_task[:result].nil? ? {:errors => [pulp_task[:exception], pulp_task[:traceback]]}.to_json : pulp_task[:result]
    }
    self.save! if not self.new_record?
    self
  end



  protected
  def setup_task_type
    unless self.task_type
      self.task_type = self.class().name
    end
  end

end
