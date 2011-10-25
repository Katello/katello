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
  clear_helpers
    
  helper_method :current_organization
  before_filter :set_locale
  before_filter :require_user,:require_org
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  after_filter :flash_to_headers
  #custom 404 (render_404) and 500 (render_error) pages

  # this is always in the top
  # order of these are important.
  rescue_from Exception do |exception|
    execute_rescue(exception, lambda{ |exception| render_error(exception)})
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    execute_rescue(exception, lambda{render_404})
  end

  rescue_from ActionController::RoutingError do |exception|
    execute_rescue(exception, lambda{render_404})
  end

  rescue_from ActionController::UnknownController do |exception|
    execute_rescue(exception, lambda{render_404})
  end

  rescue_from ActionController::UnknownAction do |exception|
    execute_rescue(exception, lambda{render_404})
  end

  rescue_from Errors::SecurityViolation do |exception|
    execute_rescue(exception, lambda{render_403})
  end

  rescue_from Errors::CurrentOrganizationNotFoundException do |exception|
    org_not_found_error(exception)
  end


  # support for session (thread-local) variables must be the last filter (except authorize)in this class
  include Katello::ThreadSession::Controller
  include AuthorizationRules
  include Menu
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
        new_notice = Notice.create(:text => notice_string, :details => details, :level => level, :global => global,
                                   :request_type => requested_action, :user_notices => [UserNotice.new(:user => current_user)])

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
      Notice.create!(:text => notice_string, :details => details, :level => level, :global => global,
                     :request_type => requested_action, :user_notices => [UserNotice.new(:user => current_user, :viewed=>false)])
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
    return if flash.blank?
    [:error, :warning, :success, :message].each do |type|
      unless flash[type].nil? or flash[type].blank?
        @enc = CGI::escape(flash[type].gsub("\n","<br \\>"))
        response.headers['X-Message'] = @enc
        response.headers['X-Message-Type'] = type.to_s
        response.headers['X-Message-Request-Type'] = requested_action
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
    return nil unless session[:current_organization_id]
    begin
      @current_org ||=  Organization.find(session[:current_organization_id])
      return @current_org
    rescue Exception => error
      log_exception error
      session.delete(:current_organization_id)
      raise Errors::CurrentOrganizationNotFoundException.new error.to_s
    end
  end

  def current_organization=(org)
    session[:current_organization_id] = org.try(:id)
  end

  def escape_html input
    CGI::escapeHTML(input)
  end

  private

  def require_org
    unless session && current_organization
      execute_after_filters
      raise Errors::SecurityViolation, _("User does not belong to an organization.")
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
      execute_after_filters
      redirect_to new_user_session_url and return false
    end
  end

  def require_no_user
    if current_user
      notice _("Welcome Back!") + ", " + current_user.username
      execute_after_filters
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

  # render a 404 page
  def render_404(exception = nil)
    if exception
        logger.info _("Rendering 404:") + "#{exception.message}"
    end
    respond_to do |format|
      format.html { render :template => "common/404", :layout => !request.xhr?, :status => 404 }
      format.atom { head 404 }
      format.xml  { head 404 }
      format.json { head 404 }
    end
    User.current = nil
  end

  # take care of 500 pages too
  def render_error(exception = nil)
    if exception
      logger.info _("Rendering 500:") + "#{exception.message}"
      errors exception.to_s
    end
    respond_to do |format|
      format.html { render :template => "common/500", :layout => "katello", :status => 500,
                                :locals=>{:error=>exception} }
      format.atom { head 500 }
      format.xml  { head 500 }
      format.json { head 500 }
    end
    User.current = nil
  end

  def retain_search_history
    begin
      # save the request in the user's search history
      unless params[:search].nil? or params[:search].blank?
        path = @_request.env['REQUEST_PATH']
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
      log_exception(error)
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
      Rails.logger.error("Received unrecognized notice: " + notice.inspect)
      items["notices"].push(notice)
    end
  end

  def requested_action
    unless controller_name.nil? or action_name.nil?
      controller_name + '___' + action_name
    end
  end

  def setup_environment_selector org, accessible
    next_env = KTEnvironment.find(params[:next_env_id]) if params[:next_env_id]

    @paths = []
    @paths = org.promotion_paths.collect{|tmp_path| [org.locker] + tmp_path}

    # reject any paths that don't have accessible envs
    @paths.reject!{|path|  (path & accessible).empty?}

    @paths = [[org.locker]] if @paths.empty?

    if @environment and !@environment.locker?
      @paths.each{|path|
        path.each{|env|
          @path = path and return if env.id == @environment.id
        }
      }
    elsif next_env
      @paths.each{|path|
        path.each{|env|
          @path = path and return if env.id == next_env.id
        }
      }
    else
      @path = @paths.first
      @environment = @path.first
    end
  end

  def pp_exception(exception)
    "#{exception.class}: #{exception.message}\n" << exception.backtrace.join("\n")
  end

  def render_panel_items(items, options, search, start)
    options[:accessor] ||= "id"
    options[:columns] = options[:col]
    
    if start == "0"
      options[:total_count] = items.count
    end
    
    items = items.search_for(search)
    
    options[:total_results] = items.count
    options[:collection] ||= items.limit(current_user.page_size).offset(start)
    
    if options[:list_partial]
      rendered_html = render_to_string(:partial=>options[:list_partial], :locals=>options)
    else
      rendered_html = render_to_string(:partial=>"common/list_items", :locals=>options) 
    end
    
    render :json => {:html => rendered_html,
                      :results_count => options[:total_count],
                      :total_items => options[:total_results],
                      :current_items => options[:collection].length }
                      
    retain_search_history
  end

  #produce a simple datastructure of a changeset for the browser
  def simplify_changeset cs

    to_ret = {:id=>cs.id.to_s, :name=>cs.name, :description=>cs.description, :timestamp =>cs.updated_at.to_i.to_s,
                          :system_templates => {},:products=>{}, :is_new => cs.state == Changeset::NEW}
    cs.system_templates.each do |temp|
      to_ret[:system_templates][temp.id] = {:id=> temp.id, :name=>temp.name}
    end

    cs.involved_products.each{|product|
      to_ret[:products][product.id] = {:id=> product.id, :name=>product.name, :provider=>product.provider.provider_type, 'package'=>[], 'errata'=>[], 'repo'=>[]}
    }

    cs.products.each {|product|
      to_ret[:products][product.id][:all] =  true
    }

    ['repo', 'errata', 'package'].each{ |type|
      cs.send(type.pluralize).each{|item|
        p item
        pid = item.product_id
        cs_product = to_ret[:products][pid]
        cs_product[type] << {:id=>item.send("#{type}_id"), :name=>item.display_name}
      }
    }
    to_ret
  end

  # for use with:   around_filter :catch_exceptions
  def catch_exceptions
    yield
  rescue Exception => error
    errors error
    #render :text => error, :status => :bad_request
    render_error(error)
  end

  def execute_after_filters
    flash_to_headers
  end

  def first_env_in_path accessible_envs, include_locker=false
    return current_organization.locker if include_locker && accessible_envs.member?(current_organization.locker)
    current_organization.promotion_paths.each{|path|
      path.each{|env|
        if accessible_envs.member?(env)
          return env
        end
      }
    }
    nil
  end

  def execute_rescue exception, renderer
    log_exception exception
    if current_user
      User.current = current_user
      renderer.call(exception)
      User.current = nil
      execute_after_filters
      return false
    else
      errors _("You must be logged in to access that page."), {:persist => false}
      execute_after_filters
      redirect_to new_user_session_url and return false
    end
  end

  def org_not_found_error exception
    logger.error exception.message
    execute_after_filters
    logout
    errors _("You current organization is no longer valid. It is possible that the organization has been deleted, please log back in to continue."),{:persist => false}
    redirect_to new_user_session_url and return false
  end


  def log_exception exception
    if exception
      logger.error exception.to_s
      logger.error exception.message
      logger.error "#{exception.inspect}"
      exception.backtrace.each { |line|
      logger.error line
      }
    end
  end

  # Parse the input provided and return the value of displayMessage. If displayMessage is not available, return "".
  # (Note: this can be used to pull the displayMessage from a Candlepin exception.)
  # This assumes that the input follows a syntax similar to:
  #   "{\"displayMessage\":\"Import is older than existing data\"}"
  def parse_display_message input
    display_message = input.include?("displayMessage") ? input.split(":\"").last.split("\"").first : ""
  end
end

