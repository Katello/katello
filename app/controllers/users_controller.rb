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
  before_filter :find_user, :only => [:edit, :update, :clear_helptips, :destroy]
  before_filter :authorize
  skip_before_filter :require_org

  def rules
    index_test = lambda{User.any_readable?}
    create_test = lambda{User.creatable?}

    read_test = lambda{@user.readable?}
    edit_test = lambda{@user.editable?}
    delete_test = lambda{@user.deletable?}
    user_helptip = lambda{true} #everyone can enable disable a helptip
    
     {
       :index => index_test,
       :items => index_test,
       :new => create_test,
       :create => create_test,
       :edit => read_test,
       :update => edit_test,
       :clear_helptips => edit_test,
       :destroy => delete_test,
       :enable_helptip => user_helptip,
       :disable_helptip => user_helptip,
     }
  end
  
  def index
    begin
      @users = User.readable.search_for(params[:search]).limit(current_user.page_size)
      retain_search_history
    rescue Exception => error
      errors error.to_s, {:level => :message, :persist => false}
      @users = User.search_for ''
    end
  end
  
  def items
    start = params[:offset]
    @users = User.readable.search_for(params[:search]).limit(current_user.page_size).offset(start)
    render_panel_items @users, @panel_options
  end

  
  def edit 
    render :partial=>"edit", :layout => "tupane_layout", :locals=>{:user=>@user, :editable=>@user.editable?}
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
    begin
      #remove the user
      @user.destroy
      if @user.destroyed?
        notice _("User '#{@user[:username]}' was deleted.")
        #render and do the removal in one swoop!
        render :partial => "common/list_remove", :locals => {:id => @id} and return
      end
      errors "", {:list_items => @user.errors.to_a}
      render :text => @user.errors, :status=>:ok
    rescue Exception => error
      errors error
      render :json=>@user.errors, :status=>:bad_request
    end
  end

  def clear_helptips
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

  def find_user
    @user = User.find params[:id]
  end
  

  def setup_options
    @panel_options = { :title => _('Users'),
                 :col => ['username'],
                 :create => _('User'),
                 :name => _('user'),
                 :ajax_scroll => items_users_path(),
                 :enable_create => User.creatable? }
  end

end
