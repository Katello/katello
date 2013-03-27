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

  def rules
    read_org = lambda { @organization.readable? }
    edit_org = lambda { @organization.editable? }

    {
      :index =>  read_org,
      :create => edit_org,
      :destroy => edit_org,
      :apply_to_all => edit_org
    }
  end

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
      :keyname => params[:keyname],
      :informable_type => inf_type,
      :organization => @organization.attributes
    }.to_json
  end

  def destroy
    inf_type = params[:informable_type]
    @organization.default_info[inf_type].delete(params[:keyname])
    @organization.save!
    render :json => {
      :keyname => params[:keyname],
      :informable_type => inf_type,
      :organization => @organization.attributes
    }.to_json
  end

  def apply_to_all
    to_apply = []
    @organization.default_info[params[:informable_type]].each do |key|
      to_apply << { :keyname => key }
    end
    systems = CustomInfo.apply_to_set(@organization.systems, to_apply)
    render :json => systems.collect { |sys| sys[:name] }.to_json
  end

  private

  def check_informable_type
    Organization.check_informable_type!(params[:informable_type],
      :message => _("Type must be one of the following [ %{list} ]") %
      { :list => Organization::ALLOWED_DEFAULT_INFO_TYPES.join(", ") }
    )
  end

end
