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

require 'util/threadsession'

class Api::ApiController < ActionController::Base
  include ActionController::HttpAuthentication::Basic

  respond_to :json
  before_filter :set_locale
  before_filter :require_user

  rescue_from Exception, :with => proc { |e| render_exception(500, e) } # catch-all

  rescue_from RestClient::ExceptionWithResponse, :with => :exception_with_response
  rescue_from ActiveRecord::RecordInvalid, :with => :invalid_record
  rescue_from Errors::NotFound, :with => proc { |e| render_exception(404, e) }

  rescue_from HttpErrors::NotFound, :with => proc { |e| render_exception(404, e) }
  rescue_from HttpErrors::BadRequest, :with => proc { |e| render_exception(400, e) }

  # support for session (thread-local) variables must be the last filter in this class
  include Katello::ThreadSession::Controller

  def set_locale
    hal = request.env['HTTP_ACCEPT_LANGUAGE']
    I18n.locale = hal.nil? ? 'en' : hal.scan(/^[a-z]{2}/).first
    logger.debug "Setting locale: #{I18n.locale}"
  end

  # override warden current_user (returns nil because there is no user in that scope)
  def current_user
    # get the logged user from the correct scope
    user(:api)
  end

  def query_params
    return @query_params if @query_params

    @query_params = params.clone
    @query_params.delete('controller')
    @query_params.delete('action')
    @query_params.delete('username')
    @query_params.delete('password')
    
    @query_params.each_pair do |k,v|
      
      if v.is_a?(String)
        if v.downcase == 'true'
          @query_params[k] = true
        elsif v.downcase == 'false'
          @query_params[k] = false
        end
      end
    end

    return @query_params
  end

  def exception_with_response(exception)
    logger.error "exception when talking to a remote client:" << pp_exception(exception)
    render :text => pp_exception(exception) , :status => exception.http_code
  end

  def invalid_record(exception)
    logger.error exception.class
    exception.record.errors.each_pair do |c,e|
      logger.error "#{c}: #{e}"
    end
    render :text => pp_exception(exception), :status => 400
  end

  def find_organization
    @organization = Organization.first(:conditions => {:cp_key => params[:organization_id].tr(' ', '_')})
    raise HttpErrors::NotFound, _("Couldn't find organization '#{params[:organization_id]}'") if @organization.nil?
    @organization
  end

  private

  def require_user
    params[:username], params[:password] = user_name_and_password(request) unless request.authorization.blank?
    authenticate! :scope => :api
  rescue => e
    logger.error "failed to authenticate API request: " << pp_exception(e)
    head :status => 500 and return false
  end

  protected
  def render_exception(status_code, exception)
    logger.error pp_exception(exception)
    respond_to do |format|
      format.json { render :json => {:errors => [ exception.message ]}, :status => status_code }
      format.all  { render :text => exception.message, :status => status_code }
    end
  end

  def pp_exception(exception)
    "#{exception.class}: #{exception.message}\n" << exception.backtrace.join("\n")
  end

end
