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
  belongs_to :system
  belongs_to :task_status


  TYPES = {
      #package tasks
     :package_install => {
          :name => _("Package Install"),
          :type => :package,
          :event_messages => {
              :running => _('Adding Package...'),
              :waiting => _('Adding Package...'),
              :finished => _('Add Package Completed'),
              :error => _('Add Package Failed'),
              :cancelled => _('Add Package Canceled'),
              :timeout => _('Add Package Timed Out')
          },
      },
      :package_update => {
          :name => _("Package Update"),
          :type => :package,
          :event_messages => {
              :running => _('Updating Package...'),
              :waiting => _('Updating Package...'),
              :finished => _('Update Package Completed'),
              :error => _('Update Package Failed'),
              :cancelled => _('Update Package Canceled'),
              :timeout => _('Update Package Timed Out')
          },
      },
      :package_remove => {
          :name => _("Package Remove"),
          :type => :package,
          :event_messages => {
              :running => _('Removing Package...'),
              :waiting => _('Removing Package...'),
              :finished => _('Remove Package Completed'),
              :error => _('Remove Package Failed'),
              :cancelled => _('Remove Package Canceled'),
              :timeout => _('Remove Package Timed Out')
          },
      },
      #package group tasks
      :package_group_install => {
          :name => _("Package Group Install"),
          :type => :package_group,
          :event_messages => {
              :running => _('Adding Package Group...'),
              :waiting => _('Adding Package Group...'),
              :finished => _('Add Package Group Completed'),
              :error => _('Add Package Group Failed'),
              :cancelled => _('Add Package Group Canceled'),
              :timeout => _('Add Package Group Timed Out')
          },
      },
      :package_group_update => {
          :name => _("Package Group Update"),
          :type => :package_group,
          :event_messages => {
              :running => _('Updating Package Group...'),
              :waiting => _('Updating Package Group...'),
              :finished => _('Update Package Group Completed'),
              :error => _('Update Package Group Failed'),
              :cancelled => _('Update Package Group Canceled'),
              :timeout => _('Update Package Group Timed Out')
          },
      },
      :package_group_remove => {
          :name => _("Package Group Remove"),
          :type => :package_group,
          :event_messages => {
              :running => _('Removing Package Group...'),
              :waiting => _('Removing Package Group...'),
              :finished => _('Remove Package Group Completed'),
              :error => _('Remove Package Group Failed'),
              :cancelled => _('Remove Package Group Canceled'),
              :timeout => _('Remove Package Group Timed Out')
          },
      },

  }.with_indifferent_access


  def self.refresh(ids)
    ids.each do |id|
      TaskStatus.find(id).refresh_pulp
    end
  end

  def self.refresh_for_system(sid)
    query = SystemTask.select(:task_status_id).joins(:task_status).where(:system_id => sid)
    ids = query.where("task_statuses.state"=>[:waiting, :running]).collect {|row| row[:task_status_id]}
    refresh(ids)
    TaskStatus.where("task_statuses.id in (#{query.to_sql})")
  end

  def self.make system, pulp_task, task_type, parameters
    task_status = PulpTaskStatus.using_pulp_task(pulp_task) do |t|
       t.organization = system.organization
       t.task_type = task_type
       t.parameters = parameters
    end
    task_status.save!

    system_task = SystemTask.create!(:system => system, :task_status => task_status)
    system_task
  end


end