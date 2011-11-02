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

class DistributionsController < ApplicationController

  before_filter :lookup_distribution

  def rules
    #TODO, only allow the user to see a distro if they have rights to a product its in
    test = lambda{true}
    {
      :show => test,
      :filelist => test,
    }
  end


  def show
    render :partial=>"show", :layout => "tupane_layout"
  end

  def filelist
    render :partial=>"filelist", :layout => "tupane_layout"
  end

  private

  def lookup_distribution
    @distribution = Glue::Pulp::Distribution.find params[:id]
  end

end
