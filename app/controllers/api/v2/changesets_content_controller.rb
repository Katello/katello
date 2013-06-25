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

class Api::V2::ChangesetsContentController < Api::V2::ApiController

  before_filter :find_changeset
  before_filter :find_content_view, :only => [:add_content_view, :remove_content_view]
  before_filter :authorize

  def rules
    cv_perm     = lambda { @changeset.environment.changesets_manageable? && @view.promotable? }
    { :add_content_view    => cv_perm,
      :remove_content_view => cv_perm
    }
  end

  api :POST, "/changesets/:changeset_id/content_views", "Add a content view to a changeset"
  param :changeset_id, :number, :desc => "id of the product to remove"
  param :content_view, Hash, :required => true do
    param :id, :number, :desc => "id of the content view to add"
  end
  def add_content_view
    @changeset.add_content_view! @view
    respond_for_create :resource => @changeset, :template => :show
  end

  api :DELETE, "/changesets/:changeset_id/content_views/:content_view_id", "Remove a content_view from a changeset"
  param :changeset_id, :number
  param :content_view_id, :number, :desc => "id of the content view to remove"
  def remove_content_view
    @changeset.remove_content_view!(@view)
    respond_for_show :resource => @changeset, :template => :show
  end

  private

  def find_changeset
    @changeset = Changeset.find_by_id(params[:changeset_id]) or
        raise HttpErrors::NotFound, _("Couldn't find changeset '%s'") % params[:changeset_id]
  end

  def find_content_view
    content_view_id = params.try(:[], :content_view).try(:[], :id) || params.try(:[], :id)
    @view           = ContentView.find_by_id(content_view_id)
    raise HttpErrors::NotFound, _("Couldn't find content view '%s'") % content_view_id if @view.nil?
  end

end
