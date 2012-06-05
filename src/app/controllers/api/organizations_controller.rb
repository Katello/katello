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

class Api::OrganizationsController < Api::ApiController

  before_filter :find_organization, :only => [:show, :update, :destroy, :products]
  before_filter :find_organization, :only => [:show, :update, :destroy, :products, :providers]

  respond_to :json
  before_filter :authorize

  def rules
    index_test = lambda{Organization.any_readable?}
    create_test = lambda{Organization.creatable?}
    read_test = lambda{@organization.readable?}
    edit_test = lambda{@organization.editable?}
    delete_test = lambda{@organization.deletable?}
    products_test = lambda{Product.any_readable?(@organization)}


    {:index =>  index_test,
      :show => read_test,
      :create => create_test,
      :update => edit_test,
      :products => products_test,
      :destroy => delete_test,
    }
  end
  def param_rules
    {
      :update => {:organization  => [:name, :description]}
    }
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/organizations", "List organizations"
  def index
    render :json => (Organization.readable.where query_params).to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/organizations/:id", "Show an organization"
  def show
    render :json => @organization
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, "/organizations", "Create an organization"
  param :description, :undef
  param :name, :undef
  def create
    render :json => Organization.create!(:name => params[:name], :description => params[:description], :cp_key => params[:name].tr(' ', '_')).to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PUT, "/organizations/:id", "Update an organization"
  param :organization, Hash do
    param :description, :undef
  end
  def update
    render :json => @organization.update_attributes!(params[:organization]).to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, "/organizations/:id", "Destroy an organization"
  def destroy
    async_job = current_user.destroy_organization_async(@organization)
    render :json => async_job, :status => 202
  end

  private

  def find_organization
    @organization = Organization.first(:conditions => {:cp_key => params[:id].tr(' ', '_')})
    raise HttpErrors::NotFound, _("Couldn't find organization '#{params[:id]}'") if @organization.nil?
    @organization
  end

end
