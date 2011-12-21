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
              :running => [N_('installing package...'),N_('installing packages...')],
              :waiting => [N_('installing package...'),N_('installing packages...')],
              :finished => [N_('%s package installed'), N_('%s (%s other packages) installed.')],
              :error=> [N_('%s package install failed'), N_('%s (%s other packages) install failed')],
              :cancelled => [N_('%s package install cancelled'), N_('%s (%s other packages) install cancelled')],
              :timed_out =>[N_('%s package install timed out'), N_('%s (%s other packages) install timed out')],
          },
         :user_message => _('Package Install scheduled by %s')

      },
      :package_update => {
          :name => _("Package Update"),
          :type => :package,
          :event_messages => {
              :running => [N_('updating package...'), N_('updating packages...')],
              :waiting => [N_('updating package...'), N_('updating packages...')],
              :finished =>[ N_('%s package updated'), N_('%s (%s other packages) updated')],
              :error => [N_('%s package update failed'), N_('%s (%s other packages) update failed')],
              :cancelled =>[N_('%s package update cancelled'), N_('%s (%s other packages) update cancelled')],
              :timed_out =>[N_('%s package update timed out'), N_('%s (%s other packages) update timed out')],
          },
          :user_message => _('Package Update scheduled by %s')
      },
      :package_remove => {
          :name => _("Package Remove"),
          :type => :package,
          :event_messages => {
              :running => [N_('removing package...'), N_('removing packages...')],
              :waiting => [N_('removing package...'), N_('removing packages...')],
              :finished => [N_('%s package removed'), N_('%s (%s other packages) removed')],
              :error => [N_('%s package remove failed'), N_('%s (%s other packages) remove failed')],
              :cancelled => [N_('%s package remove cancelled'), N_('%s (%s other packages) remove cancelled')],
              :timed_out => [N_('%s package remove timed out'), N_('%s (%s other packages) remove timed out')],
          },
          :user_message => _('Package Remove scheduled by %s')
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
          :user_message => _('Package Group Install scheduled by %s')
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
          :user_message => _('Package Group Update scheduled by %s')
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
          :user_message => _('Package Group Remove scheduled by %s')
      },

  }.with_indifferent_access

  class << self
    def pending_message_for task
      details = SystemTask::TYPES[task.task_type]
      case details[:type]
        when :package
          p = task.parameters[:packages]
          unless p && p.length > 0
            if "package_update" == task.task_type
              return _("all packages")
            end
            return ""
          end
          return n_("%s", N_("%s (%s other packages)"), p.length) % [p.first, p.length - 1]
      end

    end
    def message_for task
      details = SystemTask::TYPES[task.task_type]
      case details[:type]
        when :package
          p = task.parameters[:packages]
          unless p && p.length > 0
            if "package_update" == task.task_type
              case task.state
                when "running"
                  return "updating"
                when "waiting"
                  return "updating"
                when "error"
                  return _("all packages update failed")
                else
                  return _("all packages updated")
              end
            end
            return ""
          end
          msg = details[:event_messages][task.state]
          r = msg + [p.length]
          return n_(*r) % [p.first, p.length - 1]
        else
          return "Boo yeah"
      end
    end

    def refresh(ids)
      ids.each do |id|
        TaskStatus.find(id).refresh_pulp
      end
    end

    def refresh_for_system(sid)
      query = SystemTask.select(:task_status_id).joins(:task_status).where(:system_id => sid)
      ids = query.where("task_statuses.state"=>[:waiting, :running]).collect {|row| row[:task_status_id]}
      refresh(ids)
      TaskStatus.where("task_statuses.id in (#{query.to_sql})")
    end

    def make system, pulp_task, task_type, parameters
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

end