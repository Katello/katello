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
  before_filter :find_provider, :only => [:subscriptions, :edit, :update, :destroy]
  before_filter :require_user
  before_filter :panel_options, :only => [:index, :items]
  respond_to :html, :js

  def section_id
    'contents'
  end

  def products_repos
    @providers = current_organization.providers
    @provider = Provider.find(params[:id])
    @products = @provider.products
    render :partial => "products_repos", :locals => {:provider => @provider, :providers => @providers, :products => @products}
  end

  def subscriptions
    if !params[:provider].blank? and params[:provider].has_key? :contents
      temp_file = nil
      begin
        dir = "#{Rails.root}/tmp"
        Dir.mkdir(dir) unless File.directory? dir
        temp_file = File.new(File.join(dir, "import_#{SecureRandom.hex(10)}.zip"), 'w+', 0600)
        temp_file.write params[:provider][:contents].read
        temp_file.close
        @provider.import_manifest File.expand_path(temp_file.path)
        notice _("Subscription uploaded successfully"), {:synchronous_request => false}

      rescue Exception => error
        errors _("There was a format error with your Subscription Manifest"), {:synchronous_request => false}
        Rails.logger.error "error uploading subscriptions."
        Rails.logger.error error
        Rails.logger.error error.backtrace.join("\n")
       render :partial => "subscriptions", :locals => {:provider => @provider},:status => :bad_request and return
      end
    end

    @providers = current_organization.providers
    @provider = Provider.find(params[:id])
    # We default to none imported until we can properly poll Candlepin for status of the import
    @subscriptions = [{'productName' => _("None Imported"), "consumed" => "0", "available" => "0"}]
    begin
      all_subs = Candlepin::Owner.pools @provider.organization.cp_key
      @subscriptions = []
      all_subs.each do |sub|
        sub['providedProducts'].each do |cp_product|
          product = Product.where(:cp_id =>cp_product["productId"]).first
          if product and product.provider == @provider
            @subscriptions << sub if !@subscriptions.include? sub
          end
        end
      end
      
    rescue Exception => error
      Rails.logger.error "Error fetching subscriptions from Candlepin"
      Rails.logger.error error
      Rails.logger.error error.backtrace.join("\n")
    end
    render :partial => "subscriptions", :locals => {:provider => @provider}
  end

  def index
    begin
      @providers = Provider.search_for(params[:search]).where(:organization_id => current_organization).order('provider_type desc').limit(current_user.page_size)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @providers = Provider.search_for ''
    end

  end

  def items
    start = params[:offset]
    @providers = Provider.search_for(params[:search]).where(:organization_id => current_organization).order('provider_type desc').limit(current_user.page_size).offset(start)
    render_panel_items @providers, @panel_options
  end

  def show
    provider = Provider.find(params[:id])
    render :partial=>"common/list_update", :locals=>{:item=>provider, :accessor=>"id", :columns=>['name', 'provider_type']}
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:provider => @provider}
  end

  def new
    @provider = Provider.new
    render :partial => "new", :locals => {:provider => @provider}
  end

  def create
    begin
      @provider = Provider.create! params[:provider].merge({:organization => current_organization})
      notice _("Provider '#{@provider['name']}' was created.")
      #render :nothing => true
      render :partial=>"common/list_item", :locals=>{:item=>@provider, :accessor=>"id", :columns=>['name', 'provider_type']}

    rescue Exception => error
      Rails.logger.error error.to_s
      errors error
      render :text => error, :status => :bad_request
    end
  end

  def destroy
    @id = @provider.id
    begin
      @provider.destroy
      if @provider.destroyed?
        notice _("Provider '#{@provider[:name]}' was deleted.")
        #render and do the removal in one swoop!
        render :partial => "common/list_remove", :locals => {:id => @id}
      else
        raise
      end
    rescue Exception => e
      errors e.to_s
    end
  end

  def update

    begin
      updated_provider = Provider.find(params[:id])
      result = params[:provider].values.first

      updated_provider.name = params[:provider][:name] unless params[:provider][:name].nil?

      unless params[:provider][:description].nil?
        result = updated_provider.description = params[:provider][:description].gsub("\n",'')
      end

      updated_provider.repository_url = params[:provider][:repository_url] unless params[:provider][:repository_url].nil?
      updated_provider.provider_type = params[:provider][:provider_type] unless params[:provider][:provider_type].nil?

      updated_provider.save!
      notice _("Provider '#{updated_provider.name}' was updated.")

      respond_to do |format|
        format.html { render :text => escape_html(result) }
      end

    rescue Exception => e
      errors e.to_s

      respond_to do |format|
        format.html { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
        format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  protected

  def find_provider
    @provider = Provider.find(params[:id])
    errors _("Couldn't find provider '#{params[:id]}'") if @provider.nil?
    redirect_to(:controller => :providers, :action => :index, :organization_id => current_organization.cp_key) and return if @provider.nil?
  end

  def panel_options
        @panel_options = { :title => _('Providers'),
                 :col => ['name', 'provider_type'],
                 :create => _('Provider'),
                 :name => _('provider'),
                 :ajax_scroll=>items_providers_path()}
  end


end
