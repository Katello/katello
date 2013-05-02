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

class Api::V1::OrganizationsController < Api::V1::ApiController

  before_filter :find_organization, :only => [:show, :update, :destroy]

  respond_to :json
  before_filter :authorize

  def organization_id_keys
    [:id]
  end

  def rules
    index_test  = lambda { Organization.any_readable? }
    create_test = lambda { Organization.creatable? }
    read_test   = lambda { @organization.readable? }
    edit_test   = lambda { @organization.editable? }
    delete_test = lambda { @organization.deletable? }

    { :index   => index_test,
      :show    => read_test,
      :create  => create_test,
      :update  => edit_test,
      :destroy => delete_test,
    }
  end
  def param_rules
    {
        :create => [:name, :label, :description],
        :update => { :organization => [:name, :description] }
    }
  end

  def_param_group :organization do
    param :name, String, :desc => "name for the organization", :required => true, :action_aware => true
    param :description, String
  end

  api :GET, "/organizations", "List organizations"
  param_group :organization
  param :label, String, :desc => "label for filtering"
  def index
    respond :collection => Organization.without_deleting.readable.where(query_params)
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/organizations/:id", "Show an organization"
  def show
    respond
  end

  api :POST, "/organizations", "Create an organization"
  param_group :organization
  def create
    label = labelize_params(params)
    respond :resource => Organization.create!(:name => params[:name], :description => params[:description], :label => label)
  end

  api :PUT, "/organizations/:id", "Update an organization"
  param :organization, Hash do
    param_group :organization, Api::V1::OrganizationsController
  end
  def update
    @organization.update_attributes!(params[:organization])
    respond
  end

  api :DELETE, "/organizations/:id", "Destroy an organization. Asynchronous operation."
  def destroy
    async_job = OrganizationDestroyer.destroy @organization
    respond_for_async :resource => async_job
  end

end
