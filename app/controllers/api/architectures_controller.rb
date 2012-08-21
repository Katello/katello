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

  resource_description do 
    description <<-DOC
      The Architectures API is available only if support for Foreman is installed.
    DOC
  end


  api :GET, "/architectures", "Get list of architectures available in Foreman"
  def index
    render :json => Foreman::Architecture.all
  end

  api :GET, "/architectures/:id", "Show an architecture"
  param :id, String, "architecture name"
  def show
    render :json => Foreman::Architecture.find(params[:id])
  end

  api :POST, "/architecture", "Create new architecture in Foreman"
  param :architecture, Hash, :desc => "architecture info" do 
    param :name, String, "architecture name"
  end
  def create
    resource = Foreman::Architecture.new(params[:architecture])
    if resource.save
      render :json => resource
    end
  end

  api :PUT, "/architectures/:id", "Update an architecture record in Foreman"
  param :id, String, "architecture name"
  param :architecture, Hash, :desc => "architecture info" do 
    param :name, String, "architecture name"
  end
  def update
    resource = Foreman::Architecture.new(params[:architecture])
    resource.id = params[:id]
    if resource.save
      render :json => resource
    end
  end

  api :DELETE, "/architectures/:id", "Remove an architecture from Foreman"
  param :id, String, "architecture name"
  def destroy
    if Foreman::Architecture.delete(params[:id])
      render :nothing => true
    end
  end
end


