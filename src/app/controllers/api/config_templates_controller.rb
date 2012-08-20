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

class Api::ConfigTemplatesController < Api::ApiController

  skip_before_filter :authorize # TODO

  def index
    render :json => Foreman::ConfigTemplate.all(params.slice('order', 'search'))
  end

  def show
    render :json => Foreman::ConfigTemplate.find!(params[:id])
  end

  def create
    resource = Foreman::ConfigTemplate.new(params[:config_template])
    if resource.save!
      render :json => resource
    end
  end

  def update
    resource = Foreman::ConfigTemplate.find!(params[:id])
    resource.attributes = params[:config_template]
    if resource.save!
      render :json => resource
    end
  end

  def destroy
    if Foreman::ConfigTemplate.delete!(params[:id])
      render :nothing => true
    end
  end

  def revision
    render :json => Foreman::ConfigTemplate.revision(params[:version])
  end

  def build_pxe_default
    render :json => Foreman::ConfigTemplate.build_pxe_default
  end
end
