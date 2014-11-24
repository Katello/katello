#
# Copyright 2014 Red Hat, Inc.
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
  class Api::V2::ContentViewVersionsController < Api::V2::ApiController
    before_filter :find_content_view_version, :only => [:show, :promote, :destroy]
    before_filter :find_content_view
    before_filter :find_environment, :only => [:promote, :index]
    before_filter :authorize_promotable, :only => [:promote]
    before_filter :authorize_destroy, :only => [:destroy]

    api :GET, "/content_view_versions", N_("List content view versions")
    api :GET, "/content_views/:content_view_id/content_view_versions", N_("List content view versions")
    param :content_view_id, :identifier, :desc => N_("Content view identifier"), :required => true
    param :environment_id, :identifier, :desc => N_("Filter versions by environment"), :required => false
    param :version, String, :desc => N_("Filter versions by version number"), :required => false
    def index
      versions = @view.versions.where(params.permit(:version))
      versions = versions.in_environment(@environment) if @environment
      versions = versions.includes(:content_view).includes(:environments).includes(:composite_content_views).includes(:history => :task)

      collection = {:results  => versions.order('version desc'),
                    :subtotal => versions.count,
                    :total    => versions.count
                   }

      params[:sort_by] = 'version'
      params[:sort_order] = 'desc'

      respond(:collection => collection, :layout => 'index')
    end

    api :GET, "/content_view_versions/:id", N_("Show content view version")
    param :id, :identifier, :desc => N_("Content view version identifier"), :required => true
    def show
      respond :resource => @version
    end

    api :POST, "/content_view_versions/:id/promote", N_("Promote a content view version")
    param :id, :identifier, :desc => N_("Content view version identifier"), :required => true
    param :force, :bool, :desc => N_("force content view promotion and bypass lifecycle environment restriction")
    param :environment_id, :identifier
    def promote
      is_force = params[:force].is_a?(String) ? params[:force].to_bool : params[:force]
      task = async_task(::Actions::Katello::ContentView::Promote,
                        @version, @environment, is_force)
      respond_for_async :resource => task
    end

    api :DELETE, "/content_view_versions/:id", N_("Remove content view version")
    param :id, :identifier, :desc => N_("Content view version identifier"), :required => true
    def destroy
      task = async_task(::Actions::Katello::ContentViewVersion::Destroy, @version)
      respond_for_async :resource => task
    end

    private

    def find_content_view_version
      @version = ContentViewVersion.find(params[:id])
    end

    def find_content_view
      @view = @version ? @version.content_view : ContentView.find(params[:content_view_id])
      if @view.default? && params[:action] == "promote"
        fail HttpErrors::BadRequest, _("The default content view cannot be promoted")
      end
    end

    def find_environment
      return unless params.key?(:environment_id)
      @environment = KTEnvironment.find(params[:environment_id])
    end

    def authorize_promotable
      return deny_access unless @environment.promotable_or_removable? && @version.content_view.promotable_or_removable?
      true
    end

    def authorize_destroy
      return deny_access unless @version.content_view.deletable?
      true
    end
  end
end
