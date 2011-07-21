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

class Api::ChangesetsController < Api::ApiController

  before_filter :find_environment, :only => [:index, :create]
  before_filter :find_changeset, :only => [:show, :destroy, :update_content, :promote]
  respond_to :json

  def index
    render :json => Changeset.where(params.slice(:name, :environment_id))
  end


  def show
    render :json => @changeset.to_json(:include => [:products, :packages, :errata, :repos])
  end


  def create
    @changeset = Changeset.new(params[:changeset])
    @changeset.environment = @environment
    @changeset.save!

    render :json => @changeset
  end

  def promote
    @changeset.state = Changeset::REVIEW
    async_job = @changeset.async(:organization => @changeset.environment.organization).promote
    render :json => async_job, :status => 202
  end

  def destroy
    @changeset.destroy
    render :text => _("Deleted changeset '#{params[:id]}'"), :status => 200
  end


  def update_content

    update_items params[:patch][:products] do |action, name|
      @changeset.add_product name    if action == "+"
      @changeset.remove_product name if action == "-"
    end

    update_items params[:patch][:packages] do |action, name|
      @changeset.add_package name    if action == "+"
      @changeset.remove_package name if action == "-"
    end

    update_items params[:patch][:errata] do |action, id|
      @changeset.add_erratum id    if action == "+"
      @changeset.remove_erratum id if action == "-"
    end

    update_items params[:patch][:repos] do |action, name|
      @changeset.add_repo name    if action == "+"
      @changeset.remove_repo name if action == "-"
    end

    @changeset.save!
    render :json => @changeset.to_json(:include => [:products, :packages, :errata, :repos])
  end


  def update_items items, &block
    return if items.nil?

    for item in items do
      action = item[0,1]
      name   = item[1,item.length]

      if (action != "+") && (action != "-")
        raise Errors::PatchSyntaxException.new("Patch syntax error.")
      end

      yield action, name
    end
  end


  def find_changeset
    @changeset = Changeset.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find changeset '#{params[:id]}'") if @changeset.nil?
    @changeset
  end


  def find_environment
    @environment = KPEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @environment
  end

end
