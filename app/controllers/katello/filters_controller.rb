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
class FiltersController < Katello::ApplicationController

  helper ContentViewDefinitionsHelper

  before_filter :require_user
  before_filter :find_content_view_definition
  before_filter :find_filter, :only => [:edit, :update]
  before_filter :authorize #after find_content_view_definition, since the definition is required for authorization

  respond_to :html

  def section_id
    'contents'
  end

  def rules
    index_rule   = lambda { ContentViewDefinition.any_readable?(current_organization) }
    show_rule    = lambda { @view_definition.readable? }
    manage_rule  = lambda { @view_definition.editable? }

    {
      :index => index_rule,
      :show => show_rule,

      :new => manage_rule,
      :create => manage_rule,

      :edit => show_rule,
      :update => manage_rule,

      :destroy_filters => manage_rule
    }
  end

  def param_rules
    {
      :create => {:view_definition => [:name, :label, :description]},
      :update => [:content_view_definition_id, :id, :products, :repos, :puppet_repository_id, :filter, :locale]
    }
  end

  def index
    render :partial => "katello/content_view_definitions/filters/index",
           :locals => {:view_definition => @view_definition, :editable => @view_definition.editable?}
  end

  def new
    render :partial => "katello/content_view_definitions/filters/new", :locals => {:view_definition => @view_definition}
  end

  def create
    filter = Filter.create!(params[:filter]) do |f|
      f.content_view_definition = @view_definition
    end

    notify.success(_("Filter '%{filter}' successfully created for content view definition '%{definition}'.") %
                    {:filter => params[:filter][:name], :definition => @view_definition.name})

    render :partial => "katello/common/post_action_close_subpanel",
           :locals => {:path => edit_content_view_definition_filter_path(@view_definition, filter)}
  end

  def edit
    render :partial => "katello/content_view_definitions/filters/edit",
           :locals => {:view_definition => @view_definition, :filter => @filter,
                       :editable => @view_definition.editable?, :name => controller_display_name}
  end

  def update
    if params.key?(:products)
      products_ids = params[:products].blank? ? [] : Product.readable(current_organization).
          where(:id => params[:products]).pluck("#{Katello::Product.table_name}.id")

      @filter.product_ids = products_ids
    end

    if params[:repos]
      repo_ids = params[:repos].empty? ? [] : Repository.libraries_content_readable(current_organization).
          where(:id => params[:repos].values.flatten).pluck("#{Katello::Repository.table_name}.id")

      @filter.repository_ids = repo_ids
    end

    if params[:puppet_repository_id]
      if puppet_repo = @filter.repositories.puppet_type.first
        @filter.repositories.delete(puppet_repo)
      end

      unless params[:puppet_repository_id].blank?
        new_repo = Repository.libraries_content_readable(current_organization).find(params[:puppet_repository_id])
        @filter.repositories << new_repo
      end
    end

    @filter.save!

    notify.success((_("Successfully updated products and repositories for filter '%s'.") % @filter.name), :persist_only => true)
    render :nothing => true
  end

  def destroy_filters
    Filter.destroy(params[:filters].keys) unless params[:filters].blank?

    notify.success(_("Filters successfully deleted for content view definition '%{definition}'. Filters deleted: %{filter_names}.") %
                   {:definition => @view_definition.name, :filter_names => params[:filters].values.join(', ')})

    render :nothing => true
  end

  protected

  def find_content_view_definition
    @view_definition = ContentViewDefinition.find(params[:content_view_definition_id])
  end

  def find_filter
    id = params[:id] || params[:filter_id]
    @filter = Filter.find(id)
  end

  private

  def controller_display_name
    return 'filters'
  end

end
end
