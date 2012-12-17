
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

class ProvidersController < ApplicationController
  include AutoCompleteSearch

  before_filter :find_rh_provider, :only => [:redhat_provider]

  before_filter :find_provider, :only => [:products_repos, :show, :edit, :update, :destroy, :manifest_progress,
                                          :repo_discovery, :discovered_repos, :discover]
  before_filter :authorize #after find_provider
  before_filter :panel_options, :only => [:index, :items]
  before_filter :search_filter, :only => [:auto_complete_search]

  respond_to :html, :js

  def section_id
    'contents'
  end

  def rules
    index_test = lambda{current_organization && Provider.any_readable?(current_organization)}
    create_test = lambda{current_organization && Provider.creatable?(current_organization)}
    read_test = lambda{@provider.readable?}
    edit_test = lambda{@provider.editable?}
    delete_test = lambda{@provider.deletable?}
    {
      :index => index_test,
      :items => index_test,
      :show => index_test,
      :auto_complete_search => index_test,
      :new => create_test,
      :create => create_test,
      :edit =>read_test,
      :update => edit_test,
      :destroy => delete_test,
      :products_repos => read_test,
      :manifest_progress => edit_test,
      :redhat_provider => read_test,
      :repo_discovery => edit_test,
      :discovered_repos => edit_test,
      :discover => edit_test
    }
  end

  def param_rules
    {
        :create => {:provider => [:name, :description]}
    }
  end

  def products_repos
    @products = @provider.products
    render :partial => "products_repos", :layout => "tupane_layout", :locals => {:provider => @provider,
                                         :providers => @providers, :products => @products, :editable=>@provider.editable?,
                                         :repositories_cloned_in_envrs=>repositories_cloned_in_envrs}
  end

  def manifest_progress
    expire_page :action => :manifest_progress
    # "finished" is checked for in the javascript to see if polling for task progress should be done
    if @provider.manifest_task.nil?
      to_ret = {'state' => 'finished'}
    else
      to_ret = @provider.manifest_task.to_json
    end

    # Never cache these results since the user may close and re-open the "new" panel and no status would
    # be available for checking
    response.headers["Last-Modified"] = Time.now.httpdate
    response.headers["Expires"] = "0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Cache-Control"] = 'no-store, no-cache, must-revalidate, max-age=0, pre-check=0, post-check=0'

    render :json=>to_ret
  end

  def redhat_provider
    render :template =>"providers/redhat/show"
  end

  def items
    ids = Provider.readable(current_organization).collect{|p| p.id}
    render_panel_direct(Provider, @panel_options, params[:search], params[:offset], [:name_sort, 'asc'],
                  {:default_field => :name, :filter=>[{"id"=>ids}, {:provider_type=>[Provider::CUSTOM.downcase]}]})
  end

  def show
    provider = Provider.find(params[:id])
    render :partial=>"common/list_update", :locals=>{:item=>provider, :accessor=>"id", :columns=>['name']}
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:provider => @provider, :editable=>@provider.editable?,
                                                                       :repositories_cloned_in_envrs=>repositories_cloned_in_envrs,
                                                                       :name=>controller_display_name}
  end

  def new
    @provider = Provider.new
    render :partial => "new", :layout => "tupane_layout", :locals => {:provider => @provider}
  end

  def create
    @provider = Provider.create! params[:provider].merge({:provider_type => Provider::CUSTOM,
                                                                  :organization => current_organization})
    notify.success _("Provider '%s' was created.") % @provider['name']

    if search_validate(Provider, @provider.id, params[:search])
      render :partial=>"common/list_item", :locals=>{:item=>@provider, :initial_action=>:products_repos, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
    else
      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @provider["name"]
      render :json => { :no_match => true }
    end
  end

  def destroy
    if @provider.destroy
      notify.success _("Provider '%s' was deleted.") % @provider[:name]
      #render and do the removal in one swoop!
      render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
    end
  end

  def update
    updated_provider = Provider.find(params[:id])
    result = params[:provider].values.first

    updated_provider.name = params[:provider][:name] unless params[:provider][:name].nil?

    unless params[:provider][:description].nil?
      result = updated_provider.description = params[:provider][:description].gsub("\n",'')
    end

    updated_provider.repository_url = params[:provider][:repository_url] unless params[:provider][:repository_url].nil?
    updated_provider.provider_type = params[:provider][:provider_type] unless params[:provider][:provider_type].nil?

    updated_provider.save!
    notify.success _("Provider '%s' was updated.") % updated_provider.name

    if not search_validate(Provider, updated_provider.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % updated_provider["name"]
    end

    render :text => escape_html(result)
  end

  def repo_discovery
    render :partial=>'repo_discovery', :layout => "tupane_layout",
           :locals => {:provider => @provider, :discovered=>get_discovered_urls,
              :repositories_cloned_in_envrs=>repositories_cloned_in_envrs}
  end

  def discovered_repos
    render :json =>{:urls=>get_discovered_urls, :running=>true}
  end

  def discover
    @provider.discovery_url = params[:url]
    @provider.save!
    @provider.discover_repos
    render :text=>''
  end

  protected

  def get_discovered_urls
    urls = (@provider.discovered_repos.sort || [])
    urls.collect{|r| {:url=>r}}
  end

  def find_provider
    @provider = Provider.find(params[:id])
  end

  def find_rh_provider
    @provider = current_organization.redhat_provider
  end


  def panel_options
    @panel_options = { :title => _('Providers'),
             :col => ['name'],
             :titles => [_('Name')],
             :create => _('Provider'),
             :create_label => _('+ New Provider'),
             :name => controller_display_name,
             :ajax_load => true,
             :ajax_scroll=>items_providers_path(),
             :initial_action => :products_repos,
             :search_class => Provider,
             :enable_create => Provider.creatable?(current_organization)}
  end

  def controller_display_name
    return 'provider'
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

  def repositories_cloned_in_envrs
    cloned_repositories = @provider.repositories.select {|r| r.promoted? }
    cloned_repositories.collect {|r| [r.name, r.product.environments.select {|env| r.is_cloned_in?(env)}.map(&:name)] }
  end

=begin
  def find_subscriptions
    @provider = current_organization.redhat_provider
    cp_pools = Candlepin::Owner.pools current_organization.label
    subscriptions = Pool.index_pools cp_pools

    @grouped_subscriptions = []
    subscriptions.each do |sub|
      # Derived pools are not displayed here
      if sub.pool_derived
        next
      end

      # Only Red Hat provider subscriptions are shown
      p = Product.where(:cp_id => sub.product_id).first
      if p && p.provider_id == @provider.id
        @grouped_subscriptions << sub
      end
      #Product.where(:cp_id => sub.product_id).each { |product|
      #  if product && product.provider_id == @provider.id
      #    @grouped_subscriptions << sub
      #  end
      #}
    end

    @grouped_subscriptions
  end

  def setup_subs
    # TODO: See subscriptions_controller#reformat_subscriptions for a better(?) OpenStruct implementation

    @provider = current_organization.redhat_provider
    all_subs = Resources::Candlepin::Owner.pools @provider.organization.label
    # We default to none imported until we can properly poll Candlepin for status of the import
    @grouped_subscriptions = {}
    all_subs.each do |sub|
      # Subscriptions with the same 'stack_id' attribute are grouped together. Not all have this
      # attribute so the 'id' is used as a default since it will be unique between
      # subscriptions.
      #
      group_id = sub['id']
      sub['productAttributes'].each do |attr|
        if attr['name'] == 'stacking_id'
          group_id = attr['value']
        elsif attr['name'] == 'support_level'
          sub['support_level'] = attr['value']
        elsif attr['name'] == 'arch'
          sub['arch'] = attr['value']
        end
      end

      # Other interesting attributes
      derived = false
      sub['machine_type'] = ''
      sub['attributes'].each do |attr|
        if attr['name'] == 'virt_only'
          if attr['value'] == 'true'
            sub['machine_type'] = _('Virtual')
          elsif attr['value'] == 'false'
            sub['machine_type'] = _('Physical')
          end
        elsif attr['name'] == 'pool_derived'
          if attr['value'] == 'true'
            sub['derived'] = true
          end
        end
      end

      # Derived pools are not displayed on the providers page
      if sub['derived'] == true
        next
      end

      Product.where(:cp_id => sub['productId']).each do |product|
        if product and product.provider == @provider
          @grouped_subscriptions[group_id] ||= []
          @grouped_subscriptions[group_id] << sub if !@grouped_subscriptions[group_id].include? sub
        end
      end
x=begin TODO: Should the bundled products be displayed too?
      if sub['providedProducts'].length > 0
        sub['providedProducts'].each do |cp_product|
          product = Product.where(:cp_id => cp_product['productId']).first
          if product and product.provider == @provider
            @grouped_subscriptions[group_id] ||= []
            @grouped_subscriptions[group_id] << sub if !@grouped_subscriptions[group_id].include? sub
          end
        end
      else
        product = Product.where(:cp_id => sub['productId']).first
        if product and product.provider == @provider
          @grouped_subscriptions[group_id] ||= []
          @grouped_subscriptions[group_id] << sub if !@grouped_subscriptions[group_id].include? sub
        end
      end
x=end
    end
  end
=end
end
