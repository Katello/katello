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
   
  before_filter :setup_options, :only => [:items, :index]
  def rules
     rules = {:index => [[:create, :update, :read, :delete], :users],
         :items => [[:create, :update, :read], :users],
        :new => [[:create], :users],
         :create => [[:create], :users],
         :edit => [[:read,:update,:create], :users, params[:id]],
         :update => [[:update, :create], :users, params[:id]],
         :delete => [[:update, :create], :users, params[:id]],
     }
     rules[:clear_helptips] = rules[:edit]
     rules[:enable_helptip] = rules[:clear_helptips]
     rules[:disable_helptip] = rules[:enable_helptip]
     rules
  end
  
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
    render :partial=>"edit", :layout => "tupane_layout", :locals=>{:user=>@user}
  end
  
  def new
    @user = User.new
    render :partial=>"new", :layout => "tupane_layout", :locals=>{:user=>@user}
  end

  def create
    begin
      @user = User.new(params[:user])
      @user.save!
      notice @user.username + _(" created successfully.")
      render :partial=>"common/list_item", :locals=>{:item=>@user, :accessor=>"id", :columns=>["username"]}
    rescue Exception => error
      errors error
      render :json=>@user.errors, :status=>:bad_request
    end
  end
  
  def update
    params[:user] = {"role_ids"=>[]} unless params.has_key? :user
    params[:user].delete :username

    @user = User.where(:id => params[:id])[0]

    #Add in the own role if updating roles, cause the user shouldn't see his own role
    if params[:user][:role_ids]
      params[:user][:role_ids] << @user.own_role.id
    end

    if  @user.update_attributes(params[:user])
      notice _("User updated successfully.")
      attr = params[:user].first.last if params[:user].first
      attr ||= ""
      render :text => attr and return
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

    @user = User.find params[:id]
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

  
  
end
