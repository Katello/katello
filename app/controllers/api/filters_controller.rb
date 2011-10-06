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

class Api::FiltersController < Api::ApiController

  before_filter :find_organization, :only => [:index, :create]
  before_filter :find_filter, :only => [:show, :destroy]

  def index
    render :json => @organization.filters.to_json
  end

  def create
    @filter = Filter.create!(params[:filter]) do |f|
      f.organization = @organization
    end
    render :json => @filter.to_json
  end

  def show
    render :json => @filter.to_json
  end

  def destroy
    @filter.destroy
    render :text => _("Deleted filter '#{params[:id]}'"), :status => 200
  end

  def find_filter
    @filter = Filter.first(:conditions => {:pulp_key => params[:id]})
    raise HttpErrors::NotFound, _("Couldn't find filter '#{params[:id]}'") if @filter.nil?
    @filter
  end

end
