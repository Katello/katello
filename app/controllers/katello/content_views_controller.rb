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
  class ContentViewsController < ApplicationController

    helper ContentViewDefinitionsHelper

    before_filter :find_content_view_definition, :except => [:auto_complete]
    before_filter :authorize #after find_content_view_definition, since the definition is required for authorization
    before_filter :find_content_view, :only => [:destroy, :refresh]

    def rules
      manage_view_rule = lambda { @view_definition.publishable? }
      auto_complete_rule = lambda { ContentView.any_readable?(current_organization) }
      {
        :destroy => manage_view_rule,
        :refresh => manage_view_rule,
        :auto_complete => auto_complete_rule
      }
    end

    def destroy
      if @view.destroy
        notify.success _("Content view '%s' was deleted.") % @view[:name]
      end
      render :nothing => true
    end

    def refresh
      initial_version = @view.version(current_organization.library).try(:version)

      new_version = @view.refresh_view({:notify => true})

      notify.success(_("Started generating version %{view_version} of content view '%{view_name}'.") %
                         {:view_name => @view.name, :view_version => new_version.version})

      render :partial => 'content_view_definitions/views/view',
             :locals => { :view_definition => @view.content_view_definition, :view => @view,
                          :task => new_version.task_status }
    rescue => e
      current_version = @view.version(current_organization.library).try(:version)

      if (current_version == initial_version)
        notify.exception(_("Failed to generate a new version of content view '%{view_name}'.") %
                             {:view_name => @view.name}, e)
      else
        notify.exception(_("Failed to generate version %{view_version} of content view '%{view_name}'.") %
                             {:view_name => @view.name, :view_version => current_version}, e)
      end

      log_exception(e)
      render :text => e.to_s, :status => 500
    end

    def auto_complete
      query = "name_autocomplete:#{params[:term]}"
      org = current_organization
      content_views = ContentView.search do
        query do
          string query
        end
        filter :term, {:organization_id => org.id}
      end
      render :json=>content_views.collect{|s| {:label=>s.name, :value=>s.name, :id=>s.id}}
    rescue Tire::Search::SearchRequestFailed => e
      render :json=>Support.array_with_total
    end

    protected

    def find_content_view_definition
      @view_definition = ContentViewDefinition.find(params[:content_view_definition_id])
    end

    def find_content_view
      @view = ContentView.find(params[:id])
    end
  end
end
