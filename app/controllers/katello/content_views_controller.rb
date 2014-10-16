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
  class ContentViewsController < Katello::ApplicationController

    def auto_complete
      query = "name_autocomplete:#{params[:term]}"
      org = current_organization

      readable_ids = ContentView.readable.where(:default => false).pluck(:id)
      readable_ids << current_organization.default_content_view.id if Product.readable?

      content_views = ContentView.search do
        query do
          string query
        end
        filter :term, :organization_id => org.id
        filter :terms, :id => readable_ids
      end

      render :json => content_views.collect { |s| {:label => s.name, :value => s.name, :id => s.id} }
    rescue Tire::Search::SearchRequestFailed
      render :json => Support.array_with_total
    end

  end
end
