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

class ChangesetsController < ApplicationController
  
  before_filter :find_changeset, :except => [:index, :list, :items, :unpublished, :create]
  before_filter :find_environment, :except => [:index, :list, :items]
  before_filter :setup_options, :only => [:index, :items]
  
  rescue_from Exception, :with => :handle_exceptions

  ####
  # Changeset history methods
  ####

  #changeset history index
  def index
    setup_environment_selector(current_organization)
    @changesets = @environment.changeset_history.limit(current_user.page_size)
  end

  #extended scroll for changeset_history
  def items
    setup_environment_selector(current_organization)
    start = params[:offset]
    @changesets = @environment.changeset_history.limit(current_user.page_size).offset(start)
    render_panel_items @changesets, @panel_options
  end

  #similar to index, but only renders the actual list of the 2 pane
  def list
    @environment = KPEnvironment.find(params['env_id'])
    @changesets = @environment.changeset_history
    @columns = ['name'] #from index
    render :partial=>"list"
  end

  def edit
    render :partial=>"edit"
  end

  #list item
  def show
    render :partial=>"common/list_update", :locals=>{:item=>@changeset, :accessor=>"id", :columns=>['name']}
  end

  def show_content
    render(:partial => "changesets/changeset", :content_type => 'text/html')
  end

  def section_id
    'contents'
  end



  ####
  # Promotion methods
  ####

  def unpromoted_index
    @changesets = @environment.working_changesets
  end

  def products
    @products = @changeset.products
    render :partial=>"products", :locals=>{:changeset=>@changeset}
  end


  def dependency_size
    render :text=>@changeset.dependencies.size
  end

  def dependency_list
    @packages = @changeset.dependencies
    render :partial=>"dependency_list"
  end

  def object
    render :json => simplify_changeset(@changeset), :content_type => :json
  end

  def create
    params[:changesets][:environment_id] = @environment.id
    @changeset = Changeset.create!(params[:changesets])
    notice _("Changeset '#{@changeset["name"]}' was created.")
    render :partial=>"common/list_item", :locals=>{:item=>@changeset, :accessor=>"id", :columns=>['name']}

  def update
    send_changeset = params[:timestamp] && params[:timestamp] != @changeset.updated_at.to_i.to_s

    #if you are just updating the name, set it and return the new name
    if params[:name]
      @changeset.name = params[:name]
      @changeset.save!
      render :text=>params[:name] and return
    end

    if params.has_key? :data
      params[:data].each do |item|
        adding = item["adding"]
        type = item["type"]
        id = item["mod_id"] #id of item being added/removed
        name = item["mod_name"] #display of item being added/removed
        pid = item["product_id"];
        case type
        when "product"
          @changeset.products << Product.where(:id => id) if adding
          @changeset.products.delete Product.find(id) if !adding
        when "errata"
          @changeset.errata << ChangesetErratum.new(:errata_id=>id, :display_name=>name, :product_id => pid, :changeset => @changeset) if adding
          ChangesetErrata.destroy_all(:errata_id =>id, :changeset_id => @changeset.id) if !adding
        when "package"
          @changeset.packages << ChangesetPackage.new(:package_id=>id, :display_name=>name, :product_id => pid, :changeset => @changeset) if adding
          ChangesetPackage.destroy_all(:package_id =>id, :changeset_id => @changeset.id) if !adding

        when "repo"
            @changeset.repos << ChangesetRepo.new(:repo_id=>id, :display_name=>name, :product_id => pid, :changeset => @changeset) if adding
            ChangesetRepo.destroy_all(:repo_id =>id, :changeset_id => @changeset.id) if !adding
        end
      end
      @changeset.updated_at = Time.now
      @changeset.save!
      csu = ChangesetUser.find_or_create_by_user_id_and_changeset_id(current_user.id, cs.id)
      csu.save!

    end
    to_ret = {:timestamp=>@changeset.updated_at.to_i.to_s}
    to_ret[:changeset] = simplify_changeset(@changeset) if send_changeset
    render :json=>to_ret
  end
  
  def destroy
    name = @changeset.name
    id = @changeset.id
    @changeset.destroy
    notice _("Changeset '#{name}' was deleted.")
    render :text=>""
  end

  def promote
    begin
      @changeset.promote
      @environment.create_changeset
      # remove user edit tracking for this changeset
      ChangesetUser.destroy_all(:changeset_id => @changeset.id) 

      notice _("Promoted changeset to #{@environment.name} environment.")
    rescue Exception => e
        errors  _("Failed to promote: #{e.to_s}")
        logger.error $!, $!.backtrace.join("\n\t")
    end


    if @environment.successor
      redirect_to(:controller=>"promotions", :action => "show",
            :env_id => @environment.successor.name, :org_id =>  @environment.organization.cp_key)
    else
       redirect_to(:controller=>"promotions", :action => "show",
                  :env_id => @environment.name, :org_id =>  @environment.organization.cp_key)
    end
  end


  private



  def find_environment
    if @changeset
      @environment = @changeset.environment
    elsif params[:env_id]
      @environment = KPEnvironment.find(params[:env_id])
    else
      raise _("Couldn't find environment.")
    end
  end

  def find_changeset
    @changeset = Changeset.find(params[:id])
  end

  def setup_options
    @panel_options = { :title => _('Changesets'),
                 :col => ['name'],
                 :enable_create => false,
                 :name => _('changeset'),
                 :accessor => :id,
                 :ajax_scroll => items_changesets_path()}
  end
  
  def handle_exceptions(error)
    errors error
    render :text => error.to_s, :status => :bad_request
    Rails.logger.info error.backtrace.join("\n")
  end
  
end
