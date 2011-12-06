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
  before_filter :authorize

  def rules
    read_perm = lambda{@environment.changesets_readable?}
    manage_perm = lambda{@environment.changesets_manageable?}
    promote_perm = lambda{@environment.changesets_promotable?}
    {
      :index => read_perm,
      :show => read_perm,
      :create => manage_perm,
      :promote => promote_perm,
      :destroy =>manage_perm,
      :update_content => manage_perm,
    }
  end

  respond_to :json

  def index
    render :json => Changeset.select("changesets.*, environments.name AS environment_name").joins(:environment).where(params.slice(:name, :environment_id))
  end


  def show
    render :json => @changeset.to_json(:include => [:products, :packages, :errata, :repos, :system_templates, :distributions])
  end


  def create
    @changeset = Changeset.new(params[:changeset])
    @changeset.environment = @environment
    @changeset.save!

    render :json => @changeset
  end

  def promote
    @changeset.state = Changeset::REVIEW
    @changeset.save!
    async_job = @changeset.promote(true)
    render :json => async_job, :status => 202
  end

  def destroy
    @changeset.destroy
    render :text => _("Deleted changeset '#{params[:id]}'"), :status => 200
  end


  def update_content

    each_patch_item '+products' do |name| @changeset.add_product name end
    each_patch_item '-products' do |name| @changeset.remove_product name end

    each_patch_item '+packages' do |rec| @changeset.add_package rec[:name], rec[:product] end
    each_patch_item '-packages' do |rec| @changeset.remove_package rec[:name], rec[:product] end

    each_patch_item '+errata' do |rec| @changeset.add_erratum rec[:name], rec[:product] end
    each_patch_item '-errata' do |rec| @changeset.remove_erratum rec[:name], rec[:product] end

    each_patch_item '+repos' do |rec| @changeset.add_repo rec[:name], rec[:product] end
    each_patch_item '-repos' do |rec| @changeset.remove_repo rec[:name], rec[:product] end

    each_patch_item '+templates' do |name| @changeset.add_template name end
    each_patch_item '-templates' do |name| @changeset.remove_template name end

    each_patch_item '+distributions' do |rec| @changeset.add_distribution rec[:name], rec[:product]  end
    each_patch_item '-distributions' do |rec| @changeset.remove_distribution rec[:name], rec[:product] end

    @changeset.save!
    render :json => @changeset.to_json(:include => [:products, :packages, :errata, :repos])
  end

  def each_patch_item name, &block
    return if params[:patch].nil? or params[:patch][name].nil?

    params[:patch][name].each do |rec|
      yield rec
    end
  end

  def find_changeset
    @changeset = Changeset.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find changeset '#{params[:id]}'") if @changeset.nil?
    @environment = @changeset.environment
    @changeset
  end


  def find_environment
    @environment = KTEnvironment.find(params[:environment_id])
    raise HttpErrors::NotFound, _("Couldn't find environment '#{params[:environment_id]}'") if @environment.nil?
    @environment
  end

end
