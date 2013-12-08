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
class Task < ActiveRecord::Base

  self.primary_key = :uuid

  attr_accessible :action, :organization_id, :user_id, :uuid

  belongs_to :user
  belongs_to :organization

  belongs_to :dynflow_execution_plan,
             class_name: 'DynflowExecutionPlan',
             foreign_key: :uuid

  has_many :locks, foreign_key: :uuid

  scope :active, -> do
    joins(:dynflow_execution_plan)
    .where('dynflow_execution_plans.state != ?', :stopped)
  end

  scope :inactive, -> do
    joins(:dynflow_execution_plan)
    .where('dynflow_execution_plans.state = ?', :stopped)
  end

  def execution_plan
    @execution_plan ||= ::ForemanTasks.world.persistence.load_execution_plan(self.uuid)
  end

  def input
    main_action.respond_to?(:task_input) && main_action.task_input
  end

  def output
    main_action.respond_to?(:task_output) && main_action.task_output
  end

  def username
    user && user.username
  end

  def humanized
    { action: main_action.respond_to?(:humanized_name) && main_action.humanized_name,
      input:  main_action.respond_to?(:humanized_input) && main_action.humanized_input,
      output: main_action.respond_to?(:humanized_output) && main_action.humanized_output }
  end

  def cli_example
    main_action.respond_to?(:cli_example) && main_action.cli_example
  end

  def main_action
    return @main_action if @main_action
    main_action_id = execution_plan.root_plan_step.action_id
    @main_action = execution_plan.actions.find { |action| action.id == main_action_id }
  end

  # returns true if the task is running or waiting to be run
  def pending
    dynflow_execution_plan.state != 'stopped'
  end

end
end
