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

class SystemEventsController < ApplicationController
  skip_before_filter :authorize
  before_filter :find_system
  before_filter :authorize

  def section_id
    'systems'
  end


  def rules
    read_system = lambda{@system.readable?}
    {
      :index => read_system,
      :show => read_system,
    }
  end



  def index
    # list of events
    render :partial=>"items", :layout => "tupane_layout", :locals=>{:system => @system}
  end

  def show
    # details
    task = SystemTask.find(params[:id]).task_status
    render :partial=>"details", :layout => "tupane_layout", :locals=>{:system => @system, :task =>task}
  end

  protected
  def find_system
    @system = System.find(params[:system_id])
  end



end