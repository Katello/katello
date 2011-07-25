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

  def show
    # retrieve the search history and favorites for the user... 
    # only return histories that are associated with the page the request is received on...
    path = retrieve_path

    @search_histories = current_user.search_histories.where(:path => path).order("updated_at desc")
    @search_favorites = current_user.search_favorites.where(:path => path).order("params asc")

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
    begin
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
    rescue Exception => error
      Rails.logger.error error.to_s
      errors error.to_s
    end

    # return the search details after adding a new favorite
    show
  end

  def destroy_favorite
    begin
      current_user.search_favorites.destroy(params[:id])
    rescue Exception => error
      Rails.logger.error error.to_s
      errors error.to_s
    end

    # return the search details after removing the favorite
    show
  end

  private 

  def retrieve_path
    host = request.env['HTTP_HOST']
    # remove host details from the path
    path = request.env['HTTP_REFERER'].split(host).last
    # remove request parameters from the path
    path = path.split("?").first
  end

  def is_valid? path, query
    begin
      path_details = Rails.application.routes.recognize_path(path)
      eval(path_details[:controller].singularize.camelize).complete_for(query)
    rescue ScopedSearch::QueryNotSupported => error
      Rails.logger.error error.to_s
      errors error.to_s
      errors _("Unable to save as favorite. '#{params[:favorite]}' is an invalid search.")
      return false
    end
    return true
  end

end
