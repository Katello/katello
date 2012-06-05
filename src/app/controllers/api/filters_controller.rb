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

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/organizations/:organization_id/filters", "List filters"
  def index
    render :json => @organization.filters.to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, "/organizations/:organization_id/filters", "Create a filter"
  param :description, :undef
  param :name, :undef
  param :package_list, :undef
  def create
    @filter = Filter.create!(:name => params[:name],
      :organization => @organization,
      :description => params[:description],
      :package_list => params[:package_list]
    )
    render :json => @filter.to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PUT, "/organizations/:organization_id/filters/:id", "Update a filter"
  param :packages, :undef
  def update
    @filter.package_list = params[:packages] unless params[:packages].nil?
    @filter.save!

    render :json => @filter.to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/organizations/:organization_id/filters/:id", "Show a filter"
  def show
    render :json => @filter.to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, "/organizations/:organization_id/filters/:id", "Destroy a filter"
  def destroy
    @filter.destroy
    render :text => _("Deleted filter '#{params[:id]}'"), :status => 200
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/organizations/:organization_id/products/:product_id/filters"
  def list_product_filters
    render :json => @product.filters.to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PUT, "/organizations/:organization_id/products/:product_id/filters"
  param :filters, :undef
  def update_product_filters
    deleted_filters = @product.filters - @filters
    added_filters = @filters - @product.filters

    @product.filters -= deleted_filters
    @product.filters += added_filters

    render :json => @product.filters.to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/repositories/:repository_id/filters"
  param :inherit, :undef
  def list_repository_filters
    filters = @repository.filters
    filters += @repository.product.filters if query_params[:inherit]

    render :json => filters.uniq.to_json
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PUT, "/repositories/:repository_id/filters"
  param :filters, :undef
  def update_repository_filters
    deleted_filters = @repository.filters - @filters
    added_filters = @filters - @repository.filters

    @repository.filters -= deleted_filters
    @repository.filters += added_filters
    @repository.save!

    render :json => @repository.filters.to_json
  end

  def find_organization
    if not find_optional_organization
      @organization = @repository.organization
    end
    @organization
  end

  def find_product
    @product = @organization.products.find_by_cp_id(params[:product_id])
    raise HttpErrors::NotFound, _("Couldn't find product with id '#{params[:product_id]}'") if @product.nil?
  end

  def find_repository
    @repository = Repository.find(params[:repository_id])
    raise HttpErrors::NotFound, _("Couldn't find repository '#{params[:repository_id]}'") if @repository.nil?
    raise HttpErrors::BadRequest, _("Filters can be stored only in Library repositories.") if not @repository.environment.library?
    @repository
  end

  def find_filter
    @filter = Filter.first(:conditions => {:name => params[:id], :organization_id => @organization.id})
    raise HttpErrors::NotFound, _("Couldn't find filter '#{params[:id]}'") if @filter.nil?
    @filter
  end

  def find_filters
    @filters = Filter.where(:name => params[:filters], :organization_id => @organization.id)
    raise HttpErrors::NotFound, _("Couldn't one of the filters in '#{params[:product_id]}'") if @filters.any? {|f| f.nil?}
    @filters
  end

end
