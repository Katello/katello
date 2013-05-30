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

class PackagesController < ApplicationController
  before_filter :lookup_package
  before_filter :authorize
  helper :packages

  def rules

    view = lambda{
      !Repository.readable_in_org(current_organization).where(
          :pulp_id=>@package.repoids).empty?
    }

    {
      :show => view,
      :filelist => view,
      :changelog => view,
      :dependencies => view,
      :details => view
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

  def details
    render :partial=>"details"
  end

  private

  def lookup_package
    @package_id = params[:id]
    @package = Package.find @package_id
    raise _("Unable to find package %s")% @package_id if @package.nil?
  end

end
