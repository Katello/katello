require 'cgi'
require 'base64'

module Katello
  class ApplicationController < ::ApplicationController
    layout 'katello/layouts/katello'

    clear_helpers

    helper ::TaxonomyHelper
    helper ::ApplicationHelper
    helper ::PaginationHelper

    before_action :set_gettext_locale
    helper_method :current_organization_object
    before_action :require_org

    protect_from_forgery # See ActionController::RequestForgeryProtection for details

    # Skipping Foreman's filter that clears the user
    # from the current thread. If this filter is enabled
    # Katello's rescue_from don't have access to User.current.
    skip_around_action :clear_thread
    after_action :clear_katello_thread

    rescue_from Errors::SecurityViolation do |exception|
      execute_rescue(exception) { |_ex| render_403 }
    end

    rescue_from HttpErrors::UnprocessableEntity do |exception|
      execute_rescue(exception) { |ex| render_bad_parameters(ex) }
    end

    rescue_from ::Katello::HttpErrors::BadRequest do |exception|
      render_bad_parameters(exception)
    end

    include Menu

    # Override Foreman authorized method to support permissions on meta controllers that handle multiple routes
    def authorized
      if self.respond_to? :permission_controller
        User.current.allowed_to?(params.slice(:action, :id).merge(:controller => permission_controller))
      else
        super
      end
    end

    def section_id
      'generic'
    end

    def current_organization_object
      if !session[:current_organization_id]
        @current_org = Organization.current
        return @current_org
      else
        begin
          if @current_org.nil? && current_user
            o = Organization.find(session[:current_organization_id])
            if current_user.allowed_organizations.include?(o)
              @current_org = o
            else
              fail ActiveRecord::RecordNotFound, _("Permission Denied. User '%{user}' does not have permissions to access organization '%{org}'.") % {:user => User.current.login, :org => o.name}
            end
          end
          return @current_org
        rescue ActiveRecord::RecordNotFound => error
          log_exception error
          session.delete(:current_organization_id)
          org_not_found_error
        end
      end
    end

    def current_organization_object=(org)
      session[:current_organization_id] = org.try(:id)
    end

    private # why bother? methods below are not testable/tested

    def require_org
      unless session && current_organization_object
        redirect_to '/select_organization?toState=' + request.path
      end
    end

    # render bad params to user
    # @overload render_bad_parameters()
    #   render bad_parameters with `default_message` and status `400`
    # @overload render_bad_parameters(message)
    #   render bad_parameters with `message` and status `400`
    #   @param [String] message
    # @overload render_bad_parameters(error)
    #   render bad_parameters with `error.message` and `error.status_code` if present
    #   @param [Exception] error
    # @overload render_bad_parameters(error, message)
    #   add `message` to overload `exception.message`
    #   @param [String] message
    #   @param [Exception] error
    def render_bad_parameters(*args)
      default_message = if request.xhr?
                          _('Invalid parameters sent in the request for this operation. Please contact a system administrator.')
                        else
                          _('Invalid parameters sent. You may have mistyped the address. If you continue having trouble with this, please contact an Administrator.')
                        end

      exception = args.find { |o| o.is_a? Exception }
      message   = args.find { |o| o.is_a? String } || exception.try(:message) || default_message

      status = if exception.respond_to?(:status_code)
                 exception.status_code
               else
                 400
               end

      if exception
        log_exception exception
      else
        Rails.logger.warn message
      end

      respond_to do |format|
        format.html do
          render :template => 'common/400', :layout => !request.xhr?, :status => status,
                 :locals   => {:message => message}
        end
        format.atom { head exception.status_code }
        format.xml  { head exception.status_code }
        format.json { head exception.status_code }
      end
      User.current = nil
    end

    def execute_rescue(exception, &renderer)
      log_exception exception
      if session[:user]
        User.current = User.find(session[:user])
        renderer.call(exception)
        User.current = nil
        return false
      else
        return false if redirect_to main_app.login_users_path
      end
    end

    def org_not_found_error
      logout
      return false if redirect_to new_user_session_url
    end

    def log_exception(exception, level = :error)
      logger.send level, "#{exception} (#{exception.class})\n#{exception.backtrace.join("\n")}" if exception
    end

    def clear_katello_thread
      [:user, :organization, :location].each do |key|
        Thread.current[key] = nil
      end
    end
  end
end
