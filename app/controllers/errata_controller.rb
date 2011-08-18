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

class ErrataController < ApplicationController
    
  skip_before_filter :authorize, :only => [:packages]
  before_filter :details_auth, :only=> [:packages]
  
  before_filter :lookup_errata


  def rules
    test = lambda{true}
    {
        :show => test,
        :packages => test
    }

  end


  def show
    render :partial=>"show"
  end

  
  def packages
    render :partial=>"packages"      
  end
  
  private
  
  def details_auth
    authorize params[:controller], :show
  end    
  
  def lookup_errata
    @errata = Glue::Pulp::Errata.find(params[:id])
  end 
  
end
