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

class SearchController < ApplicationController
  include SearchHelper


  def rules
    pass = lambda{true}
    {
     :show => pass,
     :create_favorite => pass,
     :destroy_favorite => pass
    }
  end


  def show
    # retrieve the search history and favorites for the user... 
    # only return histories that are associated with the page the request is received on...
    path = retrieve_path

    @search_histories = current_user.search_histories.where("path LIKE ?", "%#{path}%").order("updated_at desc")
    @search_favorites = current_user.search_favorites.where("path LIKE ?", "%#{path}%").order("params asc")

    render :partial => "common/search"

    # clean up the histories... we will only store the last N entries in the
    # search history, so delete any past N
    if @search_histories.length > max_search_history 
      for i in (max_search_history..@search_histories.length-1)
        @search_histories[i].delete unless @search_histories[i].nil?
      end
    end
  end

  def create_favorite

    # save in the user's search favorites
    unless params[:favorite].nil? or params[:favorite].blank?
      search_string = String.new(params[:favorite])
      path = retrieve_path

      # is the search string valid?  if not, don't save it...
      if is_valid? path, search_string
        favorites = current_user.search_favorites.where(:path => path, :params => params[:favorite])
        if favorites.nil? or favorites.empty?
          # user doesn't have this favorite stored, so save it
          favorite = current_user.search_favorites.create!(:path => path, :params => params[:favorite])
        end
      end
    end

    # return the search details after adding a new favorite
    show
  end

  def destroy_favorite
    current_user.search_favorites.destroy(params[:id])

    # return the search details after removing the favorite
    show
  end

  private

  def retrieve_path
    # retrieve the 'path' from the referrer (e.g. /katello/organizations), leaving out info such as
    # protocol, fqdn and port
    path = URI(request.env['HTTP_REFERER']).path
  end

  def is_valid? path, query
      # the path may contain a service prefix (e.g. /katello).  if it does, remove it from the path when
      # checking for path validity.  This is required since the routes do not know of this prefix.
      #path = path.split(ENV['RAILS_RELATIVE_URL_ROOT']).last
      #path_details = Rails.application.routes.recognize_path(path)

      #eval(path_details[:controller].singularize.camelize).readable(current_organization).complete_for(query,
      #  {:organization_id => current_organization})

    return true
  end

end
