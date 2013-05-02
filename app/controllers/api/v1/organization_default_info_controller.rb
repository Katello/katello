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


class Api::V1::OrganizationDefaultInfoController < Api::V1::ApiController
  respond_to :json

  before_filter :find_organization
  before_filter :authorize
  before_filter :check_informable_type
  before_filter :check_apply_default_info, :only => :apply_to_all

  def rules
    read_org = lambda { @organization.readable? }
    edit_org = lambda { @organization.editable? }

    {
        :index        => read_org,
        :create       => edit_org,
        :destroy      => edit_org,
        :apply_to_all => edit_org
    }
  end

  def_param_group :informable_identifier do
    param :informable_type, String, :desc => "name of the resource", :required => true
    param :informable_id, :identifier, :desc => "resource identifier", :required => true
  end

  api :POST, '/organizations/:organization_id/default_info/:informable_type', "Create default info"
  param_group :informable_identifier
  param :keyname, String, :required => true
  def create
    inf_type = params[:informable_type]
    if @organization.default_info[inf_type].include?(params[:keyname])
      raise HttpErrors::BadRequest,
            _("Organization [ %{org} ] already contains default info [ %{info} ] for [ %{object} ]") %
                { :org => @organization.name, :info => params[:keyname], :object => inf_type.capitalize.pluralize }
    end
    @organization.default_info[inf_type] << params[:keyname]
    @organization.save!
    render :json => {
        :keyname         => params[:keyname],
        :informable_type => inf_type,
        :organization    => @organization.attributes
    }.to_json
  end

  api :DELETE, "/organizations/:organization_id/default_info/:informable_type/:informable_id/:keyname", "Delete default info"
  param_group :informable_identifier
  param :keyname, String, :desc => "Custom info key", :required => true
  def destroy
    inf_type = params[:informable_type]
    @organization.default_info[inf_type].delete(params[:keyname])
    @organization.save!
    render :json => {
        :keyname         => params[:keyname],
        :informable_type => inf_type,
        :organization    => @organization.attributes
    }.to_json
  end

  api :POST, '/organizations/:organization_id/default_info/:informable_type/apply', "Apply existing default info on all informable resources"
  param_group :informable_identifier
  def apply_to_all
    params[:async] = true if params[:async].nil?

    to_apply = []
    @organization.default_info[params[:informable_type]].each do |key|
      to_apply << { :keyname => key }
    end

    # retval will either be the Task, or an array of system names, based on whether the call is asynchronous or not
    retval = @organization.apply_default_info(params[:informable_type], to_apply, :async => params[:async])

    response = {:systems => [], :task => nil}
    if params[:async] == false
      response[:systems] = retval
    else
      response[:task] = retval
    end
    render :json => response.to_json
  end

  def apply_to_all_status
    render :json => TaskStatus.find_by_id(@organization.apply_info_task_id).to_json
  end

  private

  def check_informable_type
    Organization.check_informable_type!(
      params[:informable_type],
      :message => _("Type must be one of the following [ %{list} ]") %
        { :list => Organization::ALLOWED_DEFAULT_INFO_TYPES.join(", ") },
      :error => HttpErrors::BadRequest
    )
  end

  def check_apply_default_info
    if @organization.applying_default_info?
      raise HttpErrors::BadRequest,
        _("Organization [ %{org} ] is currently applying default custom info. Please try again later.") %
          {:org => @organization.name}
    end
  end

end
