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

class Api::FiltersController < Api::ApiController

  resource_description do
    description <<-DOC
      methods for setting package filters for repository, product or organization
    DOC
  end

  before_filter :find_repository, :only => [:list_repository_filters, :update_repository_filters]
  before_filter :find_organization, :only => [:index, :show, :destroy, :update, :create,
                                              :list_product_filters, :update_product_filters,
                                              :list_repository_filters, :update_repository_filters]
  before_filter :find_filter, :only => [:show, :destroy, :update]
  before_filter :find_product, :only => [:list_product_filters, :update_product_filters]
  before_filter :find_filters, :only => [:update_product_filters, :update_repository_filters]
  before_filter :authorize

  def rules
    index_filters = lambda { Filter.any_readable?(@organization) }
    create_filter = lambda { Filter.creatable?(@organization) }
    update_filter = lambda { Filter.any_editable?(@organization)}
    read_filter = lambda { @filter.readable? }
    delete_filter = lambda { @filter.deletable? }

    {
      :create => create_filter,
      :index => index_filters,
      :show => read_filter,
      :update => update_filter,
      :destroy => delete_filter,
      :list_product_filters => index_filters,
      :update_product_filters => create_filter,
      :list_repository_filters => index_filters,
      :update_repository_filters => create_filter
    }
  end

  def param_rules
     {
       :create => [:name, :description, :organization_id, :package_list]
     }
  end

  api :GET, "/organizations/:organization_id/filters", 'List package filters for an organization'
  param :organization_id, :identifier, :desc => "oranization identifier", :required => true
  def index
    render :json => @organization.filters.to_json
  end

  api :POST, "/organizations/:organization_id/filters", 'Create package filter for an organization'
  param :organization_id, :identifier, :desc => "oranization identifier", :required => true
  param :package_list, Array, :desc => "List of the packages to filter", :required => true
  param :name, String, :desc => "Name of the filter", :required => true
  param :description, String, :desc => "Description of the filter", :required => false
  def create
    @filter = Filter.create!(:name => params[:name],
      :organization => @organization,
      :description => params[:description],
      :package_list => params[:package_list]
    )
    render :json => @filter.to_json
  end

  api :PUT, "/organizations/:organization_id/filters/:id", "Update package filter for an organization"
  param :organization_id, :identifier, :desc => "oranization identifier", :required => true
  param :id, :identifier, :desc => "filter identifier", :required => true
  param :name, String, :desc => "filter's new name", :required => false
  param :packages, Array, :desc => "Updated list of the packages to filter", :required => true
  def update
    @filter.package_list = params[:packages] unless params[:packages].nil?
    @filter.name = params[:name] unless params[:name].blank?
    @filter.save!

    render :json => @filter.to_json
  end

  api :GET, "/organizations/:organization_id/filters/:id", "Show package filter details"
  param :organization_id, :identifier, :desc => "oranization identifier", :required => true
  param :id, :identifier, :desc => "filter identifier", :required => true
  def show
    render :json => @filter.to_json
  end

  api :DELETE, "/organizations/:organization_id/filters/:id", "Delete package filter"
  param :organization_id, :identifier, :desc => "oranization identifier", :required => true
  param :id, :identifier, :desc => "filter identifier", :required => true
  def destroy
    @filter.destroy
    render :text => _("Deleted filter '%s'") % params[:id], :status => 200
  end

  api :GET, "/organizations/:organization_id/products/:product_id/filters", "List package filters for product"
  param :organization_id, :identifier, :desc => "oranization identifier", :required => true
  param :product_id, :identifier, :desc => "product identifier", :required => true
  def list_product_filters
    render :json => @product.filters.to_json
  end

  api :PUT, "/organizations/:organization_id/products/:product_id/filters", "Update package filters for product"
  param :organization_id, :identifier, :desc => "oranization identifier", :required => true
  param :product_id, :identifier, :desc => "product identifier", :required => true
  param :filters, Array, :desc => "Updated list of filters", :required => true
  def update_product_filters
    deleted_filters = @product.filters - @filters
    added_filters = @filters - @product.filters

    @product.filters -= deleted_filters
    @product.filters += added_filters

    render :json => @product.filters.to_json
  end

  api :GET, "/repositories/:repository_id/filters", "Get package filters for repository"
  param :repository_id, :identifier, :desc => "repository identifier", :required => true
  def list_repository_filters
    filters = @repository.filters
    filters += @repository.product.filters if query_params[:inherit]

    render :json => filters.uniq.to_json
  end

  api :PUT, "/repositories/:repository_id/filters", "Update package filters for repository"
  param :repository_id, :identifier, :desc => "repository identifier", :required => true
  param :filters, Array, :desc => "Updated list of filters", :required => true
  def update_repository_filters
    deleted_filters = @repository.filters - @filters
    added_filters = @filters - @repository.filters

    @repository.filters -= deleted_filters
    @repository.filters += added_filters
    @repository.save!

    render :json => @repository.filters.to_json
  end

  private

  def find_organization
    if not find_optional_organization
      @organization = @repository.organization
    end
    @organization
  end

  def find_product
    @product = @organization.products.find_by_cp_id(params[:product_id])
    raise HttpErrors::NotFound, _("Couldn't find product with id '%s'") % params[:product_id] if @product.nil?
  end

  def find_repository
    @repository = Repository.find(params[:repository_id])
    raise HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repository.nil?
    raise HttpErrors::BadRequest, _("Filters can be stored only in the '%s' repositories.") % "Library" if not @repository.environment.library?
    @repository
  end

  def find_filter
    @filter = Filter.first(:conditions => {:name => params[:id], :organization_id => @organization.id})
    raise HttpErrors::NotFound, _("Couldn't find filter '%s'") % params[:id]  if @filter.nil?
    @filter
  end

  def find_filters
    @filters = Filter.where(:name => params[:filters], :organization_id => @organization.id)
    raise HttpErrors::NotFound, _("Couldn't one of the filters in '%s'") % params[:product_id] if @filters.any? {|f| f.nil?}
    @filters
  end

end
