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

  before_filter :lookup_package, :except=>[:auto_complete_library, :validate_name_library]
  before_filter :authorize

  def rules

    view = lambda{
      !Repository.readable_in_org(current_organization).where(
          :pulp_id=>@package.repoids).empty?
    }

    search = lambda{
      SystemTemplate.manageable?(current_organization) || Filter.any_editable?(current_organization)
    }
    {
      :show => view,
      :filelist => view,
      :changelog => view,
      :dependencies => view,
      :auto_complete_library=>search,
      :validate_name_library=>search
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
    begin
        packages = Glue::Pulp::Package.name_search(params[:term])
    rescue Tire::Search::SearchRequestFailed
        packages = []
    end
    render :json => packages
  end

  def validate_name_library
    name = params[:term]
    render :json=>Glue::Pulp::Package.search("name:#{name}", 0, 1).count
  end

  private

  def lookup_package
    @package_id = params[:id]
    @package = Glue::Pulp::Package.find @package_id
    raise _("Unable to find package %s")% @package_id if @package.nil?
  end

end
