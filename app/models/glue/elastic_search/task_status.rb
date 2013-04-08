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


module Glue::ElasticSearch::TaskStatus
  def self.included(base)
    base.send :include, Ext::IndexedModel

    base.class_eval do
      index_options :json=>{:only=> [:parameters, :result, :organization_id, :start_time, :finish_time, :task_owner_id, :task_owner_type ]},
                    :extended_json=>:extended_index_attrs

      mapping do
       indexes :start_time, :type=>'date'
       indexes :finish_time, :type=>'date'
       indexes :status, :type=>'string', :analyzer => 'snowball'
      end
    end

  end

  def extended_index_attrs
     ret = {}
     ret[:username] = user.username if user

     ret[:status] = state.to_s
     ret[:status] += " pending" if pending?
     if state.to_s == "error" || state.to_s == "timed_out"
       ret[:status] += " fail failure"
     end

     case state.to_s
       when "finished"
         ret[:status] += " completed"
       when "timed_out"
         ret[:status] += " timed out"
     end

     if task_type
       tt = task_type
       if (::System.class.name == task_owner_type)
         tt = TaskStatus::TYPES[task_type][:english_name]
       end
       ret[:status] +=" #{tt}"
     end
     ret
   end

end
