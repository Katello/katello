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

module Glue
  # triggering events on model creation/deletion for better
  # extendability
  module Event

    def self.included(base)
      base.class_eval do
        after_create :trigger_create_event
        before_destroy :trigger_destroy_event
      end
    end

    def trigger_create_event
      Glue::Event.trigger(create_event, self) if create_event
      return true
    end

    def trigger_destroy_event
      Glue::Event.trigger(destroy_event, self) if destroy_event
      return true
    end

    # define the Dynflow action to be triggered after create
    def create_event
    end

    # define the Dynflow action to be triggered before destroy
    def destroy_event
    end

    def self.trigger(event_class, *args)
      execution_plan = event_class.trigger(*args)
      execution_plan.failed_steps.each do |step|
        Notify.warning(_("Failed to perform additional action %{action}: %{message}") %
                       { :action => step.action_class.name,
                         :message => step.error['message'] },
                       { :asynchronous => true, :persist => true })
      end

      log_message = execution_plan.steps.map do |step|
        message = "#{step.action_class.name}:#{step.status}:#{step.input.inspect} -> #{step.output.inspect}"
        if step.status == 'error'
          message << "#{step.error['exception']}: #{step.error['message']}\n"
          message << step.error['backtrace'].join("\n")
        end
          message
      end.join("\n")

      if execution_plan.failed_steps.any?
        ::Logging.logger['glue'].error(log_message)
      else
        ::Logging.logger['glue'].debug(log_message)
      end
    end
  end
end
