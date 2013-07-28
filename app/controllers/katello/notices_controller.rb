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

# To change this template, choose Tools | Templates
# and open the template in the editor.

module Katello
  class NoticesController < ApplicationController

    skip_before_filter :authorize,:require_org
    before_filter :notices_authorize
    before_filter :readable_by, :only => [:auto_complete_search]

    helper_method :sort_column, :sort_direction

    def section_id
       'notifications'
    end

    def menu_definition
      { :show => :notices_menu }.with_indifferent_access
    end

    def notices_authorize
      user = current_user
      true
    end

    def show
      # TODO search by organization
      # currently doesn't handle pagination
      @notices = render_panel_direct(Notice, { }, params[:search], 0, [sort_column, sort_direction],
                                     { :filter      => { :user_ids => [current_user.id] },
                                       #:organization_id => [current_organization.id] },
                                       :skip_render => true,
                                       :page_size   => 100 })
      retain_search_history
    end

    def get_new
      if current_user
        new_notices = current_user.pop_notices current_organization

        respond_to do |format|
          format.json { render :json => { :new_notices  => new_notices,
                                          :unread_count => Notice.for_user(current_user).
                                              for_org(current_organization).count } }
        end
      else
        respond_to do |format|
          format.json { render :js => "window.location = '#{logout_path.to_json}'" }
        end
      end
    end

    def details
      # retrieve the details for the requested notice
      notice = Notice.find(params[:id])

      render :text => escape_html(notice.details)
    end

    def destroy_all
      # destroy all notices for the user
      Notice.for_user(current_user).for_org(current_organization).read.each do |notice|
        notice.users.delete(current_user)
        notice.destroy unless notice.users.any?
      end
      render :partial => "delete_all"
    end

    private

    def sort_column
      Notice.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def readable_by
      # this is used by auto search complete as input to 'readable'... to provide results based on the content readable
      # to the user...
      @readable_by = current_user
    end
  end
end
