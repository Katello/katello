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

module Katello
class Api::V2::EnvironmentsController < Api::V2::ApiController

  before_filter :find_environment, :only => [:show, :update, :destroy]
  before_filter :find_organization
  before_filter :authorize

  def rules
    manage_rule = lambda { @organization.environments_manageable? }
    view_rule   = lambda { @organization.readable? }
    {
        :create       => manage_rule,
        :update       => manage_rule,
        :destroy      => manage_rule,
        :paths        => view_rule
    }
  end

  def_param_group :environment do
    param :environment, Hash, :required => true, :action_aware => true do
      param :name, :identifier, :desc => "name of the environment (identifier)", :required => true
      param :description, String
    end
  end

  api :POST, "/organizations/:organization_id/environments", "Create an environment in an organization"
  param :organization_id, :identifier, :desc => "organization identifier"
  param_group :environment
  param :environment, Hash, :required => true do
    param :prior, :identifier, :required => true, :desc => <<-DESC
        identifier of an environment that is prior the new environment in the chain, it has to be
        either library or an environment at the end of the chain
    DESC
  end
  def create
    params[:environment][:label] = labelize_params(params[:environment]) if params[:environment]
    @environment = KTEnvironment.new(environment_params)
    @organization.environments << @environment
    fail ActiveRecord::RecordInvalid.new(@environment) unless @environment.valid?
    @organization.save!
    respond_for_show(:resource => @environment)
  end

  api :PUT, "/organizations/:organization_id/environments/:id", "Update an environment"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :id, :identifier, :desc => "environment numeric identifier", :required => true
  param :name, String, :required => true, :desc => "environment name"
  param :description, String, :desc => "environment description"
  def update
    @environment.update_attributes!(environment_params)
    respond_for_show(:resource => @environment)
  end

  api :DELETE, "/organizations/:organization_id/products/:id", "Destroy an environment"
  param :organization_id, :identifier, :desc => "organization identifier"
  param :id, :number, :desc => "environment numeric identifier"
  def destroy
    @environment.destroy
    respond_for_destroy
  end

  api :GET, "/organizations/:organization_id/environments/systems_registerable", "List environments that systems can be registered to"
  param :organization_id, :identifier, :desc => "organization identifier"
  def systems_registerable
    @environments = KTEnvironment.systems_registerable(@organization)
    respond_for_index(:collection => @environments)
  end

  api :GET, "/organizations/:organization_id/environments/paths", "List environment paths"
  def paths
    paths = @organization.promotion_paths.inject([]) do |result, path|
      result << { :path => [@organization.library] + path }
    end
    paths = [{ :path => [@organization.library] }] if paths.empty?

    respond_for_index(:collection => paths, :template => :paths)
  end

  protected

  def find_environment
    @environment = KTEnvironment.find(params[:id])
    fail HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:id] if @environment.nil?
    @organization = @environment.organization
    @environment
  end

  def environment_params
    attrs = [:name, :description]
    attrs.push(:label, :prior) if params[:action] == "create"
    params.require(:environment).permit(*attrs)
  end

end
end
