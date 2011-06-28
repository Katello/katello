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

require 'api/api_controller'
require 'util/threadsession'
require 'cgi'
require 'base64'

class ApplicationController < ActionController::Base
  layout 'katello'
  helper :all
  helper_method :current_organization
  before_filter :set_locale
  before_filter :require_user,:require_org
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :authorize
  after_filter :flash_to_headers

  # support for session (thread-local) variables must be the last filter in this class
  include Katello::ThreadSession::Controller

  def section_id
    'generic'
  end

  # Generate a notice:
  #
  # notice:              The text to include
  # options:             Optional hash containing various optional parameters.  This includes:
  #   level:               The type of notice to be generated.  Supported values include:
  #                        :message, :success (Default), :warning, :error
  #   synchronous_request: true. if this notice is associated with an event where 
  #                        the user would expect to receive a response immediately 
  #                        as part of a response. This typically applies for events 
  #                        involving things such as create, update and delete.
  #   persist:             true, if this notice should be stored via ActiveRecord.  
  #                        Note: this option only applies when synchronous_request is true.
  #   list_items:          Array of items to include with the generated notice (text).  If included,
  #                        the array will be converted to a string (separated by newlines) and
  #                        concatenated with the notice text.  This is useful in scenarios where
  #                        there are several validation errors occur from a single form submit.
  #   details:             String containing additional details.  This would typically be to store
  #                        information such as a stack trace that is in addition to the notice text.
  def notice notice, options = {}
   
    notice = "" if notice.nil?
    
    # set the defaults
    level = :success
    synchronous_request = true

    persist = true
    global = false
    details = nil

    unless options.nil?
      level = options[:level] unless options[:level].nil? 
      synchronous_request = options[:synchronous_request] unless options[:synchronous_request].nil?
      persist = options[:persist] unless options[:persist].nil?
      global = options[:global] unless options[:global].nil?
      details = options[:details] unless options[:details].nil?
    end
     
    notice_dialog = build_notice notice, options[:list_items]

    notice_string = notice_dialog["notices"].join("<br />")
    if notice_dialog.has_key?("validation_errors")
      notice_string = notice_string + notice_dialog["validation_errors"].join("<br />")
    end

    if synchronous_request
      # On a sync request, the client should expect to receive a notification 
      # immediately without polling.  In order to support this, we will send a flash
      # notice.
      if !details.nil? 
        notice_dialog["notices"].push( _("#{self.class.helpers.link_to('Click here', notices_path)} for more details."))
      end

      flash[level] = notice_dialog.to_json

      if persist
        # create & store notice... but mark as 'viewed'
        new_notice = Notice.create(:text => notice_string, :details => details, :level => level, :global => global, :user_notices => [UserNotice.new(:user => current_user)])

        unless new_notice.nil?
          user_notice = current_user.user_notices.where(:notice_id => new_notice.id).first
          unless user_notice.nil?
            user_notice.viewed = true
            user_notice.save!
          end
        end
      end
    else
      # On an async request, the client shouldn't expect to receive a notification 
      # immediately. As a result, we'll store the notification and it will be 
      # retrieved by the client on it's next polling interval.
      #
      # create & store notice... and mark as 'not viewed'
      Notice.create!(:text => notice_string, :details => details, :level => level, :global => global, :user_notices => [UserNotice.new(:user => current_user)])
    end
  end

  # Generate an error notice:
  #
  # summary:             the text to include
  # options:             Hash containing various optional parameters.  This includes:
  #   level:               The type of notice to be generated.  Supported values include:
  #                        :message, :success (Default), :warning, :error
  #   synchronous_request: true. if this notice is associated with an event where 
  #                        the user would expect to receive a response immediately 
  #                        as part of a response. This typically applies for events 
  #                        involving things such as create, update and delete.
  #   persist:             true, if this notice should be stored via ActiveRecord.  
  #                        Note: this option only applies when synchronous_request is true.
  #   list_items:          Array of items to include with the generated notice.  If included,
  #                        the array will be converted to a string (separated by newlines) and
  #                        concatenated with the notice text.  This is useful in scenarios where
  #                        there are several validation errors occur from a single form submit.
  #   details:             String containing additional details.  This would typically be to store
  #                        information such as a stack trace that is in addition to the notice text.
  def errors summary, options = {}
    options[:level] = :error
    notice summary, options
  end

  def flash_to_headers
    return if @_response.nil? or @_response.response_code == 302
    return unless request.xhr?
    return if flash.blank?
    [:error, :warning, :success, :message].each do |type|
      unless flash[type].nil? or flash[type].blank?
        @enc = CGI::escape(flash[type].gsub("\n","<br \\>"))
        response.headers['X-Message'] = @enc
        response.headers['X-Message-Type'] = type.to_s
        flash.delete(type)  # clear the flash
        return
      end
    end
  end

  def set_locale
    I18n.locale = extract_locale_from_accept_language_header
    logger.debug "Setting locale: #{I18n.locale}"
  end

  def current_organization
    return false unless session[:current_organization_id]
    @current_org ||=  Organization.find(session[:current_organization_id])
  end

  def current_organization=(org)
    session[:current_organization_id] = org.try(:id)
  end

  rescue_from 'Errors::SecurityViolation' do |exception|
    logger.warn exception.message
    #logger.debug pp_exception exception
    if current_user
      render_403
    else
      errors _("You must be logged in to access that page."), {:persist => false}
      redirect_to new_user_session_url and return false
    end
  end

  def escape_html input
    CGI::escapeHTML(input)
  end

  private
  # TODO: default organization will be stored within the logged user - this method will be removed
  def require_org
    unless session && current_organization
      logout
      errors _("You must have at least one organization in your database to access that page. Might need to run 'rake db:seed'"), {:persist => false}
      redirect_to new_user_session_url and return false
    end
  end


  def require_user
    if current_user
      #user logged in

      #redirect to originally requested page
      if session[:original_uri] != nil
        redirect_to session[:original_uri]
        session[:original_uri] = nil
      end

      return true
    else
      #user not logged
      errors _("You must be logged in to access that page."), {:persist => false}

      #save original uri and redirect to login page
      session[:original_uri] = request.fullpath
      redirect_to new_user_session_url and return false
    end
  end

  def require_no_user
    if current_user
      notice _("Welcome Back!") + ", " + current_user.username
      redirect_to dashboard_index_url
      return false
    end
  end

  def current_user
    user
  end

  # temp code to setup i18n, might want to consider looking at a rails plugin that is more robust
  def extract_locale_from_accept_language_header
    hal = request.env['HTTP_ACCEPT_LANGUAGE']
    hal.nil? ? 'en' : hal.scan(/^[a-z]{2}/).first
  end

  # authorize the user for the requested action
  def authorize(ctrl = params[:controller], action = params[:action])

    user = current_user
    user = User.anonymous unless user
    logger.debug "Authorizing #{current_user.username} for #{ctrl}/#{action}"
    allowed = user.allowed_to?(action, ctrl)
    if allowed
      return true
    else
      raise Errors::SecurityViolation, "User #{current_user.username} is not allowed to access #{params[:controller]}/#{params[:action]}"
    end
  end

  # render 403 page
  def render_403
    respond_to do |format|
      format.html { render :template => "common/403", :layout => !request.xhr?, :status => 403 }
      format.atom { head 403 }
      format.xml  { head 403 }
      format.json { head 403 }
    end
    return false
  end
  
  def retain_search_history
    begin
      # save the request in the user's search history
      unless params[:search].nil? or params[:search].blank?
        path = @_request.env['PATH_INFO']
        histories = current_user.search_histories.where(:path => path, :params => params[:search])
        if histories.nil? or histories.empty?
          # user doesn't have this search stored, so save it
          histories = current_user.search_histories.create!(:path => path, :params => params[:search])
        else
          # user already has this search in their history, so just update the timestamp, so that it shows as most recent
          histories.first.update_attribute(:updated_at, Time.now)
        end
      end
    rescue Exception => error
      Rails.logger.error error.to_s
    end
  end

  def build_notice notice, list_items
    items = { "notices" => [] }

    if notice.kind_of? Array
      notice.each do |item|
        handle_notice_type item, items
      end
    elsif notice.kind_of? String
      unless list_items.nil? or list_items.length == 0
        notice = notice + list_items.join("<br />")  
      end
      items["notices"].push(notice)
    else
      handle_notice_type notice, items
    end
    return items
  end

  def handle_notice_type notice, items
    if notice.kind_of? ActiveRecord::RecordInvalid
      items["validation_errors"] = notice.record.errors.full_messages.to_a
      return items
    elsif notice.kind_of? RestClient::InternalServerError
      items["notices"].push(notice.response)
      return items
    elsif notice.kind_of? RuntimeError
      items["notices"].push(notice.message)
    else
      items["notices"].push(notice)
    end
  end

  def setup_environment_selector org
    @paths = []
    @paths = org.promotion_paths.collect{|tmp_path| [org.locker] + tmp_path}
    @paths = [[org.locker]] if @paths.empty?
    @path = @paths.first if @path.nil?
    @environment = @path.first if @environment.nil?
  end

  def pp_exception(exception)
    "#{exception.class}: #{exception.message}\n" << exception.backtrace.join("\n")
  end

  def render_panel_items(items, options)
    options[:accessor] ||= "id"
    options[:collection] = items
    options[:columns] = options[:col]
    if options[:list_partial]
      render :partial=>options[:list_partial], :locals=>options
    else
      render :partial=>"common/list_items", :locals=>options
    end
  end

  #produce a simple datastructure of a changeset for the browser
  def simplify_changeset cs

    to_ret = {:id=>cs.id.to_s, :timestamp =>cs.updated_at.to_i.to_s, :products=>{}}

    cs.involved_products.each{|product|
      to_ret[:products][product.id] = {:id=> product.id, :name=>product.name, :provider=>product.provider.provider_type, 'package'=>[], 'errata'=>[], 'repo'=>[]}
    }

    cs.products.each {|product|
      to_ret[:products][product.id][:all] =  true;
    }

    ['repo', 'errata', 'package'].each{ |type|
      cs.send(type.pluralize).each{|item|
        p item
        pid = item.product_id
        cs_product = to_ret[pid]
        cs_product[type] << {:id=>item.send("#{type}_id"), :name=>item.display_name}
      }
    }

    to_ret
  end


end

