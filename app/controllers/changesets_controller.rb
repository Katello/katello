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

class ChangesetsController < ApplicationController
  include AutoCompleteSearch
  include BreadcrumbHelper
  include ChangesetBreadcrumbs

  before_filter :find_changeset, :except => [:index, :items, :list, :create, :new, :auto_complete_search]
  before_filter :find_environment, :except => [:auto_complete_search]
  before_filter :authorize
  before_filter :setup_options, :only => [:index, :items, :auto_complete_search]

  after_filter :update_editors, :only => [:update]

  def rules
    read_perm = lambda{@environment.changesets_readable?}
    manage_perm = lambda{@environment.changesets_manageable?}
    update_perm =  lambda {@environment.changesets_manageable? && update_artifacts_valid?}
    apply_perm = lambda{ (@changeset.promotion? && @environment.changesets_promotable?) || (@changeset.deletion? && @environment.changesets_deletable?)}
    {
      :index => read_perm,
      :items => read_perm,
      :list => read_perm,
      :show => read_perm,
      :new => manage_perm,
      :create => manage_perm,
      :edit => read_perm,
      :update => update_perm,
      :destroy =>manage_perm,
      :object => read_perm,
      :auto_complete_search => read_perm,
      :apply => apply_perm,
      :changeset_status => read_perm
    }
  end

  ####
  # Changeset history methods
  ####

  #changeset history index
  def index
    accessible_envs = KTEnvironment.changesets_readable(current_organization)
    setup_environment_selector(current_organization, accessible_envs)
    render :index, :locals=>{:accessible_envs => accessible_envs}
  end

  #extended scroll for changeset_history
  def items
    render_panel_direct(Changeset, @panel_options, params[:search], params[:offset], [:name_sort, 'asc'],
        {:default_field => :name, :filter=>[{:environment_id=>[@environment.id]}, {:state=>[Changeset::PROMOTED, Changeset::DELETED]}]})
  end

  def edit
    render :partial=>"edit", :locals=>{:editable=>@environment.changesets_manageable?, :name=>controller_display_name}
  end

  #list item
  def show
    render :partial=>"common/list_update", :locals=>{:item=>@changeset, :accessor=>"id", :columns=>['name']}
  end

  def section_id
    'contents'
  end

  ####
  # Promotion methods
  ####

  def object
    render :json => simplify_changeset(@changeset), :content_type => :json
  end

  def new
    @changeset = Changeset.new
    render :partial=>"new", :locals => {:changeset_type => params[:changeset_type]}
  end

  def create
    if params[:changeset][:action_type].blank? ||
       params[:changeset][:action_type] == Changeset::PROMOTION

      if @next_environment.blank?
        notify.error _("Please create at least one environment.")
        render :nothing => true, :status => :not_acceptable
        return
      else
        env_id = @next_environment.id
        type = Changeset::PROMOTION
      end
    else
      env_id = @environment.id
      type = Changeset::DELETION
    end
    @changeset = Changeset.create_for(type, :name => params[:changeset][:name],
                                      :description => params[:changeset][:description],
                                      :environment_id => env_id)

    notify.success _("Promotion Changeset '%s' was created.") % @changeset["name"]
    bc = {}
    add_crumb_node!(bc, changeset_bc_id(@changeset), '', @changeset.name, ['changesets'],
                    {:client_render => true}, {:is_new=>true})
    render :json => {
      'breadcrumb' => bc,
      'id' => @changeset.id,
      'changeset' => simplify_changeset(@changeset)    }
  end

  def update
    send_changeset = params[:timestamp] && params[:timestamp] != @changeset.updated_at.to_i.to_s

    #if you are just updating the name, set it and return the new name
    if params[:name]
      @changeset.name = params[:name]
      @changeset.save!

      render :json => {:name=> params[:name], :timestamp => @changeset.updated_at.to_i.to_s}
      return
    end

    if params[:description]
      @changeset.description = params[:description]
      @changeset.save!

      render :json => {:description=> params[:description], :timestamp => @changeset.updated_at.to_i.to_s}
      return
    end

    if params[:state]
      raise _('Invalid state') if !["review", "new"].index(params[:state])
      if send_changeset
        to_ret = {}
        to_ret[:changeset] = simplify_changeset(@changeset) if send_changeset
        render :json => to_ret, :status => :bad_request
        return
      end
      @changeset.state = Changeset::REVIEW if params[:state] == "review"
      @changeset.state = Changeset::NEW if params[:state] == "new"
      @changeset.save!
      render :json => {:timestamp => @changeset.updated_at.to_i.to_s}
      return
    end

    render :text => "The promotion changeset is currently under review, no modifications can occur during this phase.",
           :status => :bad_request if @changeset.state == Changeset::REVIEW
    render :text => "This promotion changeset is already promoted, no content modifications can be made.",
               :status => :bad_request if @changeset.state == Changeset::PROMOTED

    if params.has_key? :data
      params[:data].each do |item|
        adding = item["adding"]
        type   = item["type"]
        id     = item["item_id"]   #id of item being added/removed
        case type
          when "content_view"
            @changeset.remove_content_view! ContentView.find(id) if !adding

            if adding
              view, component_views = @changeset.add_content_view!(ContentView.find(id), true)

              unless component_views.blank?
                notify.message(_("The following content views were automatically added to changeset '%{changeset}'"\
                                 " for composite view '%{composite_view}': %{component_views}") %
                               {:changeset => @changeset.name, :composite_view => view.name,
                                :component_views => component_views.map(&:name).join(', ')},
                               {:asynchronous => false})
                send_changeset = true
              end
            end
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
    @changeset.destroy
    notify.success _("Promotion Changeset '%s' was deleted.") % name
    render :text=>""
  end

  def apply
    messages = {}
    if !params[:confirm] && @environment.prior.library?
      syncing = []
      errors = []

      # TODO: CONTENT VIEW IN PROGRESS - to check if refresh is in progress... this will be done in separate commit
      #@changeset.involved_products.each{|prod|
      #  prod.repos(current_organization.library).each{ |repo|
      #    status = repo.sync_status
      #    syncing << repo.name if status.state == PulpSyncStatus::RUNNING
      #    errors << repo.name if status.state == PulpSyncStatus::ERROR
      #  }
      #}
      #messages[:syncing] =  syncing if !syncing.empty?
      #messages[:error] =  errors if !errors.empty?
    end

    to_ret = {}
    if !messages.empty?
      to_ret[:warnings] = render_to_string(:partial=>'warning', :locals=>messages)
    else
      @changeset.apply :notify => true, :async => true
      if @changeset.promotion?
        notify.success _("Started content promotion to %{env} environment using '%{changeset}'") % {:env => @environment.name, :changeset => @changeset.name}
      else
        notify.success _("Started content deletion from %{env} environment using '%{changeset}'") % {:env => @environment.name, :changeset => @changeset.name}
      end
      # remove user edit tracking for this changeset
      ChangesetUser.destroy_all(:changeset_id => @changeset.id)
    end
    render :json=>to_ret
  rescue => e
    notify.exception _("Failed to apply changeset."), e
    render :text=>e.to_s, :status=>500
  end

  def changeset_status
    progress = @changeset.task_status.progress
    state = @changeset.state
    to_ret = {'id' => 'changeset_' + @changeset.id.to_s, 'state' => state, 'progress' => progress.to_i}
    render :json=>to_ret
  end

  private

  def find_environment
    if @changeset
      @environment = @changeset.environment
    elsif params[:env_id]
      @environment = KTEnvironment.find(params[:env_id])
    else
      #didnt' find an environment, just do the first the user has access to
      list = KTEnvironment.changesets_readable(current_organization).where(:library=>false).order(:name)
      @environment ||= list.first || current_organization.library
    end

    if params[:next_env_id]
      @next_environment = KTEnvironment.find(params[:next_env_id])
    end
  end

  def update_editors
    usernames = @changeset.users.collect { |c| User.where(:id => c.user_id ).order("updated_at desc")[0].username }
    usernames.delete(current_user.username)
    response.headers['X-ChangesetUsers'] = usernames.to_json
  end

  def find_changeset
    @changeset = Changeset.find(params[:id])
  end

  def setup_options
    @panel_options = { :title => _('Changesets'),
                 :col => ['name'],
                 :titles => [_('Name')],
                 :enable_create => false,
                 :create_label => _('+ New Changeset'),
                 :name => controller_display_name,
                 :accessor => :id,
                 :ajax_load => true,
                 :ajax_scroll => items_changesets_path(),
                 :search_class=>Changeset}
  end


  def controller_display_name
    return 'changeset'
  end

  private

  #produce a simple datastructure of a changeset for the browser
  def simplify_changeset cs
    to_ret = {:id => cs.id.to_s, :name => cs.name, :type => cs.action_type, :description => cs.description,
              :timestamp => cs.updated_at.to_i.to_s, :content_views => {},
              :is_new => cs.state == Changeset::NEW, :state => cs.state}

    cs.content_views.each do |view|
      to_ret[:content_views][view.id] = {:id => view.id, :name => view.name}
    end

    to_ret
  end

  def update_artifacts_valid?
    if params.has_key?(:data)
      params[:data].each do |item|
        return false if !update_item_valid?(item["type"], item["item_id"])
      end
    end
    true
  end

  def update_item_valid?(type, id)
    item = ContentView.find(id) if type == "content_view"
    (item && item.readable?) ? true : false
  end

end
