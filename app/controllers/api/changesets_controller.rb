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

class Api::ChangesetsController < Api::ApiController

  before_filter :find_environment, :only => [:index, :create]
  before_filter :find_changeset, :only => [:show, :destroy]
  respond_to :json

  def index
    render :json => @environment.working_changesets
  end

  def show
    render :json => @changeset
  end

  def create
    @changeset = Changeset.new(params[:changeset])
    @changeset.environment = @environment
    @changeset.save!

    render :json => @changeset
  end

  def destroy
    @changeset.destroy
    render :text => _("Deleted changeset '#{params[:id]}'"), :status => 200
  end

  def find_changeset
    @changeset = Changeset.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find changeset '#{params[:id]}'") if @changeset.nil?
    @changeset
  end

  def find_environment
    @environment = KPEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @environment
  end

end
