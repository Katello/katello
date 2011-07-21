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
  include AutoCompleteSearch
  include BreadcrumbHelper
  
  before_filter :find_changeset, :except => [:index, :list, :items, :create, :new, :auto_complete_search]
  before_filter :find_environment, :except => [:index, :list, :items, :auto_complete_search]
  before_filter :setup_options, :only => [:index, :items, :auto_complete_search]

  after_filter :update_editors, :only => [:update]

  around_filter :catch_exceptions

  ####
  # Changeset history methods
  ####

  #changeset history index
  def index
    @environment = current_organization.locker.successor || current_organization.locker
    setup_environment_selector(current_organization)
    @changesets = @environment.changeset_history.search_for(params[:search]).limit(current_user.page_size)
    retain_search_history
  end

  #extended scroll for changeset_history
  def items
    @environment = KPEnvironment.find(params['env_id'])
    setup_environment_selector(current_organization)
    start = params[:offset]
    @changesets = @environment.changeset_history.search_for(params[:search]).limit(current_user.page_size).offset(start)
    render_panel_items @changesets, @panel_options
    retain_search_history
  end

  #similar to index, but only renders the actual list of the 2 pane
  def list
    @environment = KPEnvironment.find(params['env_id'])
    @changesets = @environment.changeset_history.search_for(params[:search]).limit(current_user.page_size)
    @columns = ['name'] #from index
    render :partial=>"list"
  end

  def edit
    render :partial=>"edit", :layout => "tupane_layout"
  end

  #list item
  def show
    render :partial=>"common/list_update", :locals=>{:item=>@changeset, :accessor=>"id", :columns=>['name'], :chgusers=>changeset_users}
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


  def new
    render :partial=>"new", :layout => "tupane_layout"
  end

  def create
    @changeset = Changeset.create!(:name=>params[:name], :environment_id=>@next_environment.id)
    notice _("Changeset '#{@changeset["name"]}' was created.")
    bc = {}
    add_crumb_node!(bc, changeset_bc_id(@changeset), products_changeset_path(@changeset), @changeset.name, ['changesets'],
                    {:client_render => true}, {:is_new=>true})
    render :json => {
      'breadcrumb' => bc,
      'id' => @changeset.id,
      'changeset' => simplify_changeset(@changeset)
    }
  end

  def update
    send_changeset = params[:timestamp] && params[:timestamp] != @changeset.updated_at.to_i.to_s

    #if you are just updating the name, set it and return the new name
    if params[:name]
      @changeset.name = params[:name]
      @changeset.save!
      render :text=>params[:name] and return
    end

    if params[:state]
      raise _('Invalid state') if !["review", "new"].index(params[:state])
      if send_changeset
        to_ret = {}
        to_ret[:changeset] = simplify_changeset(@changeset) if send_changeset
        render :json=>to_ret, :status=>:bad_request and return
      end
      @changeset.state = Changeset::REVIEW if params[:state] == "review"
      @changeset.state = Changeset::NEW if params[:state] == "new"
      @changeset.save!
      render :json=>{:timestamp=>@changeset.updated_at.to_i.to_s} and return
    end

    render :text => "The changeset is currently under review, no modifications can occur during this phase.",
           :status => :bad_request if @changeset.state == Changeset::REVIEW
    render :text => "This changeset is already promoted, no content modifications can be made.",
               :status => :bad_request if @changeset.state == Changeset::PROMOTED



    if params.has_key? :data
      params[:data].each do |item|
        adding = item["adding"]
        type = item["type"]
        id = item["item_id"] #id of item being added/removed
        name = item["item_name"] #display of item being added/removed
        pid = item["product_id"]
        case type
        when "product"
          @changeset.products << Product.where(:id => id) if adding
          @changeset.products.delete Product.find(id) if !adding
        when "errata"
          @changeset.errata << ChangesetErratum.new(:errata_id=>id, :display_name=>name,
                                              :product_id => pid, :changeset => @changeset) if adding
          ChangesetErrata.destroy_all(:errata_id =>id, :changeset_id => @changeset.id) if !adding
        when "package"
          @changeset.packages << ChangesetPackage.new(:package_id=>id, :display_name=>name, :product_id => pid,
                                              :changeset => @changeset) if adding
          ChangesetPackage.destroy_all(:package_id =>id, :changeset_id => @changeset.id) if !adding

        when "repo"
            @changeset.repos << ChangesetRepo.new(:repo_id=>id, :display_name=>name, :product_id => pid, :changeset => @changeset) if adding
            ChangesetRepo.destroy_all(:repo_id =>id, :changeset_id => @changeset.id) if !adding
        end
      end
      @changeset.updated_at = Time.now
      @changeset.save!
      csu = ChangesetUser.find_or_create_by_user_id_and_changeset_id(current_user.id, @changeset.id)
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
    if @changeset.state != Changeset::REVIEW
      errors _("The changeset must be moved to the review stage before promotion")
      render text=>"", :status => 500
    end


    begin
      @changeset.promote
      # remove user edit tracking for this changeset
      ChangesetUser.destroy_all(:changeset_id => @changeset.id) 
      notice _("Promoted '#{@changeset.name}' to #{@environment.name} environment"), :synchronous_request=>false
    rescue Exception => e
        errors  "Failed to promote: #{e.to_s}", :synchronous_request=>false
        logger.error $!, $!.backtrace.join("\n\t")
    end



    render :text=>url_for(:controller=>"promotions", :action => "show",
          :env_id => @environment.name, :org_id =>  @environment.organization.cp_key)

  end


  private

  def find_environment
    if @changeset
      @environment = @changeset.environment
    elsif params[:env_id]
      @environment = KPEnvironment.find(params[:env_id])
    else
      text = _("Couldn't find environment.")
      errors text
      execute_after_filters
      render :text=>text, :status=>:bad_request and return
    end
    @next_environment = KPEnvironment.find(params[:next_env_id]) if params[:next_env_id]
    @next_environment ||= @environment.successor
  end

  def update_editors
    usernames = @changeset.users.collect { |c| User.where(:id => c.user_id ).order("updated_at desc")[0].username }
    usernames.delete(current_user.username)
    response.headers['X-ChangesetUsers'] = usernames.to_json
  end

  def find_changeset
    begin
      @changeset = Changeset.find(params[:id])
    rescue Exception => error
      errors error.to_s
      execute_after_filters
      render :text=>error.to_s, :status=>:bad_request
    end
  end

  def setup_options
    @panel_options = { :title => _('Changesets'),
                 :col => ['name'],
                 :enable_create => false,
                 :name => _('changeset'),
                 :accessor => :id,
                 :ajax_scroll => items_changesets_path()}
  end

end
