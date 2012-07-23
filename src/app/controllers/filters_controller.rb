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

class FiltersController < ApplicationController

  include AutoCompleteSearch

  before_filter :panel_options, :only=>[:index, :items]
  before_filter :find_filter, :only=>[:edit, :update, :destroy,
                                      :packages, :add_packages, :remove_packages,
                                      :products, :update_products, :show]
  before_filter :authorize

  def rules
    create = lambda{Filter.creatable?(current_organization)}
    index_test = lambda{Filter.any_readable?(current_organization)}
    readable = lambda{@filter.readable?}
    editable = lambda{@filter.editable?}
    deletable = lambda{@filter.deletable?}
    {
      :create => create,
      :new => create,
      :index => index_test,
      :items => index_test,
      :edit => readable,
      :update=>editable,
      :destroy=>deletable,
      :packages=>readable,
      :show=>readable,
      :add_packages=>editable,
      :remove_packages=>editable,
      :products=>readable,
      :update_products=>editable
    }
  end

  def param_rules
     {
       :create => {:filter => [:name, :description]},
       :update => {:filter => [:name, :description]}
     }
  end

  def index
    products = Product.readable(current_organization)
    editable_products = Product.editable(current_organization)
    products.sort!{|a,b| a.name <=> b.name}
    @product_hash = {}
    products.each{|prod|
      repos = []
      prod.repos(current_organization.library).sort{|a,b| a.name <=> b.name}.each{|repo|
        repos << {:name=>repo.name, :id=>repo.id}
      }
      @product_hash[prod.id] = {:name=>prod.name, :repos=>repos, :id=>prod.id,
                                :editable=>editable_products.include?(prod)}
    }
    
    render "index"
  end

  def items
    render_panel_direct(Filter, @panel_options, params[:search], params[:offset], [:name_sort, :asc],
      {:default_field => :name, :filter=>{:organization_id=>[current_organization.id]}})
  end

  def show
    render :partial => "common/list_update", :locals=>{:item=>@filter, :accessor=>"id", :columns=>['name']}
  end

  def update
    options = params[:filter]
    to_ret = ""
    if options[:name]
      @filter.name = options[:name]
      to_ret =  @filter.name
    elsif options[:description]
      @filter.description = options[:description]
      to_ret = @filter.description
    end

    if not search_validate(Filter, @filter.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % @filter["name"]
    end

    @filter.save!
    notify.success _("Package Filter '%s' has been updated.") % @filter.name

    if not search_validate(Filter, @filter.id, params[:search])
      notify.message _("'%s' no longer matches the current search criteria.") % @filter["name"], :asynchronous => false
    end

    render :text=>to_ret
  end

  def edit
    render :partial => "edit", :layout => "tupane_layout", :locals => {:filter => @filter, :editable=>@filter.editable?,
                                                                       :name=>controller_display_name}
  end

  def new
    @filter = Filter.new
    render :partial => "new", :layout => "tupane_layout"
  end

  def create
    @filter = Filter.create!(params[:filter].merge({:organization_id=>current_organization.id}))
    notify.success N_("Filter %s created successfully.") % @filter.name
    if !search_validate(Filter, @filter.id, params[:search])

      notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @filter.name
      render :json => { :no_match => true }
    else
      render :partial=>"common/list_item", :locals=>{:item=>@filter, :initial_action=>"packages", :accessor=>"id",
                                                     :columns=>['name'], :name=>controller_display_name}
    end
  end

  def products
    render :partial => "products", :layout => "tupane_layout", :locals => {:filter => @filter, :editable=>@filter.editable?,
                                                                       :name=>controller_display_name}
  end

  def update_products
    if params[:products]
      existing_editable = @filter.products.editable(current_organization)

      new_editable = params[:products].empty? ? []:Product.editable(current_organization).where(:id=>params[:products])

      #remove unneeded ones
      (existing_editable - new_editable).each{|prod|
        prod = Product.find(prod.id) #reload readonly obj
        prod.filters.delete(@filter)
        prod.save!
      }
      #add new ones
      (new_editable - existing_editable).each{|prod|
        prod = Product.find(prod.id) #reload readonly obj
        prod.filters << @filter
        prod.save!
      }
    end

    if params[:repos]
      #deal with the repos now
      existing_editable_repos = @filter.repositories.editable_in_library(current_organization)
      new_editable_repos = params[:repos].empty? ? []:Repository.editable_in_library(current_organization).where(:id=>params[:repos].values.flatten)
      #remove unneeded ones
      (existing_editable_repos - new_editable_repos).each{|repo|
        repo = Repository.find(repo.id) #reload readonly obj
        repo.filters.delete(@filter)
        repo.save!
      }
      #add new ones
      (new_editable_repos - existing_editable_repos).each{|repo|
        repo = Repository.find(repo.id) #reload readonly obj
        repo.filters << @filter
        repo.save!
      }
    end
    @filter.save!


    notify.success _("Sucessfully updated '%s' package filter.") % @filter.name
    render :text=>''
  end

  def packages
    render :partial => "packages", :layout => "tupane_layout", :locals => {:filter => @filter, :editable=>@filter.editable?,
                                                                       :name=>controller_display_name}
  end

  def add_packages
    pkgs = params[:packages]
    @filter.package_list += (pkgs)
    @filter.package_list.uniq!
    @filter.save!
    render :json=>pkgs
  end

  def remove_packages
    pkgs = params[:packages]
    @filter.package_list -= pkgs
    @filter.save!
    render :text=>""
  end

  def destroy
    @filter.destroy
    notify.success _("Package Filter %s deleted.") % @filter.name
    render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
  end

  def section_id
    'contents'
  end

  private

  def find_filter
    @filter = Filter.find(params[:id])
  end

  def panel_options
    @panel_options = {
        :title => _('Package Filters'),
        :col => ['name'],
        :titles => [_('Name')],
        :create => _('Filter'),
        :create_label => _('+ New Filter'),
        :name => controller_display_name,
        :ajax_scroll=>items_filters_path(),
        :enable_create=> Filter.creatable?(current_organization),
        :initial_action=>:packages,
        :ajax_load=>true,
        :search_class=>Filter
    }
  end

  def controller_display_name
    return 'filter'
  end

end
