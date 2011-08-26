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

# To change this template, choose Tools | Templates
# and open the template in the editor.

class NoticesController < ApplicationController
  skip_before_filter :authorize,:require_org
  before_filter :notices_authorize
  include AutoCompleteSearch
  helper_method :sort_column, :sort_direction

  def notices_authorize
    user = current_user
    user = User.anonymous unless user
    true
  end

  def show
    begin
      @notices = current_user.notices.search_for(params[:search]).order(sort_column + " " + sort_direction)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @notices = current_user.notices.search_for ''
    end
  end

  def get_new
    # obtain the list of notices that user has not yet seen.
    new_notices = Notice.select("notices.id, text, level").where("user_notices.user_id = ? AND user_notices.viewed = ?", current_user, false).joins(:user_notices)

    # flag these notices as viewed for the user.  this will ensure the user is only notified once.
    new_notices.each do |notice|
      user_notice = current_user.user_notices.where(:notice_id => notice.id).first
      user_notice.viewed = true
      user_notice.save!
    end

    respond_to do |format|
      format.json { render :json => {:new_notices => new_notices, :unread_count => current_user.user_notices.length} }
    end
  end

  def details
    begin
      # retrieve the details for the requested notice
      notice = Notice.find(params[:id])

      respond_to do |format|
        format.html { render :text => escape_html(notice.details)}
      end

    rescue Exception => e
      errors e.to_s

      respond_to do |format|
        format.html { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
        format.js { render :partial => "layouts/notification", :status => :bad_request, :content_type => 'text/html' and return}
      end
    end
  end

  def dismiss
    notice = Notice.find(params[:id])

    notice.users.delete(current_user)
    notice.destroy unless notice.users.any?

    respond_to do |format|
      format.json { render :json => "ok" }
    end
  end

  def destroy_all
    begin
      # destroy all notices for the user
      for notice in current_user.notices
        notice.users.delete(current_user)
        notice.destroy unless notice.users.any?
      end    

    rescue Exception => error
      errors error.to_s
    end

    redirect_to :action => "show"
  end

  private

  def sort_column
    Notice.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
