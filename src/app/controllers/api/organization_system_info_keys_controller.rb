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


class Api::OrganizationSystemInfoKeysController < Api::ApiController
  respond_to :json

  before_filter :find_organization
  before_filter :authorize

  def rules
    index_test = lambda{@organization.readable?}
    create_test = lambda{@organization.editable?}
    delete_test = lambda{@organization.editable?}
    apply_test = lambda{@organization.editable?}

    {
      :index =>  index_test,
      :create => create_test,
      :destroy => delete_test,
      :apply_to_all => apply_test
    }
  end

  def create
    raise HttpErrors::BadRequest, _("A keyname must be provided") if params[:keyname].nil?
    @organization.system_info_keys << params[:keyname] unless @organization.system_info_keys.include?(params[:keyname])
    @organization.save!
    render :json => @organization.system_info_keys.to_json
  end

  def index
    render :json => @organization.system_info_keys.to_json
  end

  def destroy
    raise HttpErrors::BadRequest, _("A keyname must be provided") if params[:keyname].nil?
    @organization.system_info_keys.delete(params[:keyname])
    @organization.save!
    render :json => @organization.system_info_keys.to_json
  end

  # apply default system custom info to all existing systems
  def apply_to_all
    to_apply = []
    @organization.system_info_keys.each do |k|
      to_apply << {:keyname => k, :value => "_"}
    end
    affected = []
    @organization.systems.each do |s|
      to_apply.each do |a|
        if s.custom_info.where(:keyname => a[:keyname]).empty?
          s.custom_info.create!(a)
          affected << s
        end
      end
    end
    render :json => affected.collect {|s| s[:name]}.uniq.to_json
  end

  private

  def find_organization
    @organization = Organization.first(:conditions => {:label => params[:organization_id].tr(' ', '_')})
    raise HttpErrors::NotFound, _("Couldn't find organization '#{params[:organization_id]}'") if @organization.nil?
    @organization
  end

end
