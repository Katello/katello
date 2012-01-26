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

class PackagesController < ApplicationController
	
  before_filter :package_details_auth, :only=> [:filelist, :changelog, :dependencies]
  before_filter :lookup_package, :except=>[:auto_complete_library]
  before_filter :authorize

  def rules
    #TODO, only allow the user to see a package if they have rights to a product its in
    test = lambda{true}
    {
      :show => test,
      :filelist => test,
      :changelog => test,
      :dependencies => test,
      :auto_complete_library=>test

    }
  end

	def show
		render :partial=>"show", :layout => "tupane_layout"
	end
	
	def filelist
        render :partial=>"filelist", :layout => "tupane_layout"
	end
	
	def changelog
        render :partial=>"changelog", :layout => "tupane_layout"
	end 
	
  def dependencies
      render :partial=>"dependencies", :layout => "tupane_layout"
  end 	

  def auto_complete_library
    name = params[:term]
    render :json=>Glue::Pulp::Package.name_search(name)
  end

  private
  
  def package_details_auth
    authorize params[:controller], :show
  end    
  
  def lookup_package
    @package_id = params[:id] 
    @package = Glue::Pulp::Package.find @package_id      
  end

end
