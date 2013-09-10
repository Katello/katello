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

module Glue::ElasticSearch::Job
  def self.included(base)
    base.send :include, Ext::IndexedModel

    base.class_eval do
      index_options :json => {:only => [:job_owner_id, :job_owner_type]},
                    :extended_json => :extended_index_attrs
    end
  end

  def extended_index_attrs
    ret = {}

    first_task = self.task_statuses.first
    unless first_task.nil?
      ret[:username] = first_task.user.username
      ret[:parameters] = first_task.parameters
    end
    ret
  end
end
