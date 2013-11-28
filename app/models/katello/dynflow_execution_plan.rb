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
class DynflowExecutionPlan < ActiveRecord::Base

  self.table_name  = 'dynflow_execution_plans'
  self.primary_key = :uuid

  def self.create_or_update(*args)
    raise "Read only model - it's managed by Dynflow persistence layer"
  end
end
end
