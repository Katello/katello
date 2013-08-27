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

class Api::V1::ChangesetsContentController < Api::V1::ApiController

  before_filter :find_changeset!
  before_filter :find_content_view!, :only => [:add_content_view, :remove_content_view]
  before_filter :authorize

  def rules
    cv_perm     = lambda { @changeset.environment.changesets_manageable? && @view.promotable? }
    { :add_content_view    => cv_perm,
      :remove_content_view => cv_perm
    }
  end

  api :POST, "/changesets/:changeset_id/content_views", "Add a content view to a changeset"
  param :content_view_id, :number, :desc => "The id of the content view to add"
  def add_content_view
    @changeset.add_content_view!(@view)
    render :text => _("Added content view '%s'") % @view.name, :status => 200
  end

  api :DELETE, "/changesets/:changeset_id/content_views/:id", "Remove a content_view from a changeset"
  def remove_content_view
    render_after_removal @changeset.remove_content_view!(@view),
                         :success   => _("Removed content view '%s'") % params[:id],
                         :not_found => _("content view '%s' not found in the changeset") % params[:id]
  end

  private

  def find_changeset!
    @changeset = Changeset.find(params[:changeset_id])
    @changeset
  end

  def find_content_view!
    id    = params[:action] == "add_content_view" ? params[:content_view_id] : params[:id]
    @view = ContentView.find_by_id(id)
    raise HttpErrors::NotFound, _("Couldn't find content view '%s'") % id if @view.nil?
  end

  def render_after_removal(removed_objects, options = {})
    unless removed_objects.blank?
      rend = { :text => options[:success], :status => 200 }
    else
      rend = { :text => options[:not_found], :status => 404 }
    end
    raise ArgumentError if rend[:text].nil?
    render(rend)
  end

end
