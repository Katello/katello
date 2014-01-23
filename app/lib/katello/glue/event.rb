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

module Katello
module Glue
  # triggering events on model creation/deletion for better
  # extendability
  module Event

    def self.included(base)
      base.class_eval do
        after_create :trigger_create_event
        after_commit :execute_action
        before_destroy :trigger_destroy_event
      end
    end

    def trigger_create_event
      plan_action(create_event, self) if create_event
      return true
    end

    def trigger_destroy_event
      plan_action(destroy_event, self) if destroy_event
      return true
    end

    # define the Dynflow action to be triggered after create
    def create_event
    end

    # define the Dynflow action to be triggered before destroy
    def destroy_event
    end

    def plan_action(event_class, *args)
      @execution_plan = ::ForemanTasks.dynflow.world.plan(event_class, *args)
      planned        = @execution_plan.state == :planned
      unless planned
        errors = @execution_plan.steps.values.map(&:error).compact
        # we raise error so that the whole transaction is rollbacked
        fail errors.map(&:message).join('; ')
      end
    end

    def execute_action
      if @execution_plan
        ::ForemanTasks.dynflow.world.execute(@execution_plan.id)
      end
      return true
    end

    def self.trigger(event_class, *args)
      run = ::ForemanTasks.trigger(event_class, *args)
      ::Logging.logger['glue'].debug("Started plan with #{run.id}")
      run.finished.wait
      ::Logging.logger['glue'].debug("Finished plan with #{run.id}")
    end
  end
end
end
