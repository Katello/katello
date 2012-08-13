#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::ArchitecturesController < Api::ApiController

  skip_before_filter :authorize # TODO

  def index
    render :json => Foreman::Architecture.all
  end

  def show
    render :json => Foreman::Architecture.find(params[:id])
  end

  def create
    resource = Foreman::Architecture.new(params[:architecture])
    if resource.save
      render :json => resource
    end
  end

  def update
    resource = Foreman::Architecture.new(params[:architecture])
    resource.id = params[:id]
    if resource.save
      render :json => resource
    end
  end

  def destroy
    if Foreman::Architecture.delete(params[:id])
      render :nothing => true
    end
  end
end


