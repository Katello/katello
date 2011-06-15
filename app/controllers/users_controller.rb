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

class UsersController < ApplicationController
  include AutoCompleteSearch
  
  def section_id
     'operations'
  end
   
  # We don't want authorization on helptips, as they are a function of a user
  skip_before_filter :authorize, :only => [:enable_helptip, :disable_helptip, :clear_helptips]
  before_filter :authorize_update, :only => [:clear_helptips]
  before_filter :setup_options, :only => [:items, :index]

  
  def index
    begin
      @users = User.search_for(params[:search]).limit(current_user.page_size)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @users = User.search_for ''
    end
  end
  
  def items
    start = params[:offset]
    @users = User.search_for(params[:search]).limit(current_user.page_size).offset(start)
    render_panel_items @users, @panel_options
  end
  
  def setup_options
    @panel_options = { :title => _('Users'), 
                 :col => ['username'], 
                 :create => _('User'),
                 :name => _('user'),
                 :ajax_scroll => items_users_path()}
  end
  
  def edit 
    @user = User.where(:id => params[:id])[0]
    render :partial=>"edit", :locals=>{:user=>@user}
  end
  
  def new
    @user = User.new
    render :partial=>"new", :locals=>{:user=>@user}
  end

  def create
    @user = User.new(params[:user])
    if @user.save
            notice @user.username + _(" created successfully.")
      #render :json=>@user
      render :partial=>"common/list_item", :locals=>{:item=>@user, :accessor=>"id", :columns=>["username"]}
    else
      errors @user.errors
      render :json=>@user.errors, :status=>:bad_request
    end
  end
  
  def update

    params[:user].delete :username
    @user = User.where(:username => params[:id])[0]

    #Add in the own role if updating roles, cause the user shouldn't see his own role
    if params[:user][:role_ids]
      params[:user][:role_ids] << @user.own_role.id
    end

    if  @user.update_attributes(params[:user])
      notice _("User updated successfully.")
      attr = params[:user].first.last if params[:user].first
      attr ||= ""
      render :text => escape_html(attr) and return
    end
    errors "", {:list_items => @user.errors.to_a}
    render :text => @user.errors, :status=>:ok
  end

  def destroy
    @id = params[:id]
    @user = User.where(:id => @id)[0]
    begin
      #remove the user
      @user.destroy
      if @user.destroyed?
        notice _("User '#{@user[:username]}' was deleted.")
        #render and do the removal in one swoop!
        render :partial => "common/list_remove", :locals => {:id => @id}
      else
        raise
      end
    rescue Exception => e
      errors e.to_s
    end
  end

  def clear_helptips
    @user = User.where(:username => params[:id])[0]
    @user.clear_helptips
    notice _("Disabled help tips have been re-enabled.")
    render :text => _("Cleared")
  end

  def enable_helptip
    current_user.enable_helptip params[:key]
    render :text => ""
  end

  def disable_helptip
    current_user.disable_helptip params[:key]
    render :text => ""
  end

  private

  def authorize_update
    authorize(params[:controller], "update")
  end
  
  
end
