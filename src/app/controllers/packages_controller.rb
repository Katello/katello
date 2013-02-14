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

  before_filter :lookup_package, :except=>[:auto_complete_library, :auto_complete_nvrea_library, :validate_name_library]
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
      :auto_complete_nvrea_library=>search,
      :validate_name_library=>search
    }
  end

	def show
		render :partial=>"show"
	end

	def filelist
    render :partial=>"filelist"
	end

	def changelog
    render :partial=>"changelog"
	end

  def dependencies
    render :partial=>"dependencies"
  end

  def auto_complete_library
    begin
        repos = current_organization.library.repositories.collect{|r| r.pulp_id}
        packages = Package.autocomplete_name(params[:term], repos)
    rescue Tire::Search::SearchRequestFailed
        packages = []
    end
    render :json => packages
  end

  def auto_complete_nvrea_library
    begin
        repos = current_organization.library.repositories.collect{|r| r.pulp_id}
        packages = Package.autocomplete_nvrea(params[:term], repos)
    rescue Tire::Search::SearchRequestFailed
        packages = []
    end
    render :json => packages.collect{|p| {:label=>p.nvrea, :id=>p.id}}
  end


  def validate_name_library
    name = params[:term]
    render :json=>Package.search("name:#{name}", 0, 1).count
  end

  private

  def lookup_package
    @package_id = params[:id]
    @package = Package.find @package_id
    raise _("Unable to find package %s")% @package_id if @package.nil?
  end

end
