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


class Api::OrganizationDefaultInfoController < Api::ApiController
  respond_to :json

  before_filter :find_organization
  before_filter :authorize
  before_filter :check_keyname, :except => :apply_to_all
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
    unless @organization.default_info[inf_type].include?(params[:keyname])
      @organization.default_info[inf_type] << params[:keyname]
    end
    @organization.save!
    render :json => @organization.default_info[inf_type].to_json
  end

  def destroy
    inf_type = params[:informable_type]
    @organization.default_info[inf_type].delete(params[:keyname])
    @organization.save!
    render :json => @organization.default_info[inf_type].to_json
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

  def check_keyname
    raise HttpErrors::BadRequest, _("A keyname must be provided") if params[:keyname].nil?
  end

  def check_informable_type
    unless Organization::ALLOWED_DEFAULT_INFO_TYPES.include?(params[:informable_type])
      raise HttpErrors::BadRequest, _("Type must be one of the following [ %(list)s ]") %
        Organization::ALLOWED_DEFAULT_INFO_TYPES.join(", ")
    end
  end

end
