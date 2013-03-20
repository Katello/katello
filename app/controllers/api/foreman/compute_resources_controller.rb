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

class Api::Foreman::ComputeResourcesController < Api::Foreman::SimpleCrudController

  resource_description do
    description <<-DOC
      The Architectures API is available only if support for Foreman is installed.
    DOC
  end

  def_param_group :compute_resource do
    param :compute_resource, Hash, :desc => "compute resource info", :required => true, :action_aware => true do
      param :name, String, :required => true
      param :provider, String, :desc => "Providers include #{::Foreman::ComputeResource::PROVIDERS.join(', ')}", :required => true
      param :url, String, :desc => "URL for Libvirt, Ovirt, and Openstack", :required => true
      param :description, String
      param :user, String, :desc => "Username for Ovirt, EC2, Vmware, Openstack. Access Key for EC2."
      param :password, String, :desc => "Password for Ovirt, EC2, Vmware, Openstack. Secret key for EC2"
      param :uuid, String, :desc => "for Ovirt, Vmware Datacenter"
      param :region, String, :desc => "for EC2 only"
      param :tenant, String, :desc => "for Openstack only"
      param :server, String, :desc => "for Vmware"
    end
  end

  self.foreman_model = ::Foreman::ComputeResource

  def common_json_options
    {:root => :compute_resource, :except => [:password]}
  end

  api :GET, "/compute_resources", "Get list of compute resources available in Foreman"
  def index
    super
  end

  api :GET, "/compute_resources/:id", "Show an compute resource"
  param :id, String, "compute resource name", :required => true
  def show
    super
  end

  api :POST, "/compute_resources", "Create new compute resource in Foreman"
  param_group :compute_resource
  def create
    res = ::Foreman::ComputeResource.new_provider(params[:compute_resource])
    render :json => res.as_json if res.save!
  end

  api :PUT, "/compute_resources/:id", "Update an compute resource record in Foreman"
  param :id, String, "compute resource name", :required => true
  param_group :compute_resource
  def update
    super
  end

  api :DELETE, "/compute_resources/:id", "Remove an compute resource from Foreman"
  param :id, String, "compute resource name", :required => true
  def destroy
    super
  end
end


