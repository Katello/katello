
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

module Katello
  class ProvidersController < Katello::ApplicationController
    #include AutoCompleteSearch

    before_filter :find_rh_provider, :only => [:redhat_provider]

    before_filter :find_provider, :only => [:products_repos, :show, :edit, :update, :destroy, :manifest_progress,
                                            :repo_discovery, :discovered_repos, :discover, :cancel_discovery,
                                            :new_discovered_repos, :create_discovered_repos]
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
        :new_discovered_repos => edit_test,
        :cancel_discovery=>edit_test,
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
      render :partial => "products_repos", :locals => {:provider => @provider,
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
      ids = Provider.all.collect{ |provider| provider.id }

      offset = params[:offset] || 0
      render_panel_direct(Provider, @panel_options, params[:search], 0, [:name_sort, 'asc'],
                    {:default_field => :name, :filter=>[{"id"=>ids}, {:provider_type=>[Provider::CUSTOM.downcase]}]})
    end

    def show
      provider = Provider.find(params[:id])
      render :partial=>"common/list_update", :locals=>{:item=>provider, :accessor=>"id", :columns=>['name']}
    end

    def edit
      render :partial => "edit", :locals => {:provider => @provider, :editable=>@provider.editable?,
                                                                         :repositories_cloned_in_envrs=>repositories_cloned_in_envrs,
                                                                         :name=>controller_display_name}
    end

    def new
      @provider = Provider.new
      render :partial => "new", :locals => {:provider => @provider}
    end

    def create
      @provider = Provider.create! params[:katello_provider].merge({:provider_type => Provider::CUSTOM})
      notify.success _("Provider '%s' was created.") % @provider['name']

      if search_validate(Provider, @provider.id, params[:search])
        render :partial=>"katello/common/list_item", :locals=>{:item=>@provider, :initial_action=>:products_repos, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
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
      running = @provider.discovery_task.nil? ? false : !@provider.discovery_task.finished?
      render :partial=>'repo_discovery',
             :locals => {:provider => @provider, :discovered=>get_discovered_urls,
                :running=>running,
                :repositories_cloned_in_envrs=>repositories_cloned_in_envrs}
    end

    def discovered_repos
      running = @provider.discovery_task.nil? ? false : !@provider.discovery_task.finished?
      render :json =>{:urls=>get_discovered_urls, :running=>running}
    end

    def new_discovered_repos
      urls = params[:urls] || []
      render :partial=>'new_discovered_repos', :locals=>{:urls=>urls}
    end

    def cancel_discovery
      @provider.discovery_task = nil
      @provider.save!
      render :nothing=>true
    end

    def discover
      @provider.discovery_url = params[:url]
      @provider.save!
      @provider.discover_repos(true)
      render :nothing=>true
    end

    protected

    def get_discovered_urls
      urls = @provider.discovered_repos.try(:sort) || []
      urls.collect do |url|
        path = url.sub(@provider.discovery_url, '')
        path = "/#{path}" if path[0] != '/'

        all_repos = Repository.where(:feed=>url).in_environments_products([current_organization.library.id],
                                                              @provider.products.pluck(:id))
        existing = {}
        all_repos.each do |repo|
          existing[repo.product.name] ||= []
          existing[repo.product.name] << repo.name
        end

        {:url=>url, :path=>path, :existing=>existing}
      end
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
               :ajax_scroll=>items_katello_providers_path(),
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
  end
end
