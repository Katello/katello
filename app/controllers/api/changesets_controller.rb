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

  before_filter :find_changeset, :only => [:show, :update, :destroy, :promote, :apply, :dependencies]
  before_filter :find_environment
  before_filter :authorize

  def rules
    read_perm    = lambda { @environment.changesets_readable? }
    manage_perm  = lambda { @environment.changesets_manageable? }
    promote_perm = lambda { @changeset.promotion? && @environment.changesets_promotable? }

    apply_perm = lambda{ (@changeset.promotion? && @environment.changesets_promotable?) || (@changeset.deletion? && @environment.changesets_deletable?)}

    { :index        => read_perm,
      :show         => read_perm,
      :dependencies => read_perm,
      :create       => manage_perm,
      :update       => manage_perm,
      :promote      => promote_perm,
      :apply        => apply_perm,
      :destroy      => manage_perm,
    }
  end

  respond_to :json

  def_param_group :changeset do
    param :changeset, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "The name of the changeset", :required => true
      param :description, String, :desc => "The description of the changeset"
    end
  end

  api :GET, "/organizations/:organization_id/environments/:environment_id/changesets", "List changesets in an environment"
  param :name, String, :desc => "An optional changeset name to filter upon"
  def index
    changesets = Changeset.select("changesets.*, environments.name AS environment_name").
        joins(:environment).where(params.slice(:name, :environment_id))
    render :json => changesets
  end

  api :GET, "/changesets/:id", "Show a changeset"
  def show
    render :json => @changeset.to_json(:include => [:products, :packages, :errata, :repos,
                                                    :distributions, :content_views])
  end

  api :PUT, "/changesets/:id", "Update a changeset"
  param_group :changeset
  def update
    @changeset.attributes = params[:changeset].slice(:name, :description)
    @changeset.save!

    render :json => @changeset
  end

  api :GET, "/changesets/:id/dependencies", "List the Depenencies for a changeset"
  def dependencies
    render :json => @changeset.calc_dependencies.to_json
  end

  api :POST, "/organizations/:organization_id/environments/:environment_id/changesets", "Create a changeset"
  param_group :changeset
  param :changeset, Hash do
    param :type, ["PROMOTION", "DELETION"], :required => true
  end
  def create
    cs_type = params[:changeset][:type]
    if cs_type == 'PROMOTION'
      @changeset = PromotionChangeset.new(params[:changeset])
    elsif cs_type == 'DELETION'
      @changeset = DeletionChangeset.new(params[:changeset])
    else
      raise HttpErrors::UnprocessableEntity, _("Unknown changeset type, must be PROMOTION or DELETION: %s") % cs_type
    end

    @changeset.environment = @environment
    @changeset.save!

    render :json => @changeset
  end

  # DEPRICATED - TODO: Note this in the new API doc format
  api :POST, "/changesets/:id/promote", "Promote a changeset into a new envrionment."
  def promote
    @changeset.state = Changeset::REVIEW
    @changeset.save!
    async_job = @changeset.apply :async => true
    render :json => async_job, :status => 202
  end

  def apply
    @changeset.state = Changeset::REVIEW
    @changeset.save!
    async_job = @changeset.apply :async => true
    render :json => async_job, :status => 202
  end

  api :DELETE, "/changesets/:id", "Destroy a changeset"
  def destroy
    @changeset.destroy
    render :text => _("Deleted changeset '%s'") % params[:id], :status => 200
  end

  private

  def find_changeset
    @changeset = Changeset.find(params[:id])
    raise HttpErrors::NotFound, _("Couldn't find changeset '%s'") % params[:id] if @changeset.nil?
    @environment = @changeset.environment
    @changeset
  end

  def find_environment
    if @changeset
      @environment = @changeset.environment
    elsif params[:environment_id]
      @environment = KTEnvironment.find(params[:environment_id])
      raise HttpErrors::NotFound, _("Couldn't find environment '%s'") % params[:environment_id] if @environment.nil?
      @environment
    end
  end

end
