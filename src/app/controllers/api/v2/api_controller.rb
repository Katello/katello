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

class Api::V2::ApiController < Api::ApiController

  include Api::Version2
  include Api::V2::Rendering

  rescue_from StandardError, :with => proc { |e| render_exception(HttpErrors::INTERNAL_ERROR, e) } # catch-all
  rescue_from HttpErrors::WrappedError, :with => proc { |e| render_wrapped_exception(e) }

  rescue_from RestClient::ExceptionWithResponse, :with => :exception_with_response
  rescue_from ActiveRecord::RecordInvalid, :with => :process_invalid
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from Errors::NotFound, :with => proc { |e| render_exception(HttpErrors::NOT_FOUND, e) }

  rescue_from(Errors::SecurityViolation, :with => proc do |e|
    logger.warn pp_exception(e, :with_body => false, :with_backtrace => false)
    render_exception_without_logging(HttpErrors::FORBIDDEN, e)
  end)
  rescue_from Errors::ConflictException, :with => proc { |e| render_exception(HttpErrors::CONFLICT, e) }
  rescue_from Errors::UnsupportedActionException, :with => proc { |e| render_exception(HttpErrors::BAD_REQUEST, e) }
  rescue_from Errors::UsageLimitExhaustedException, :with => proc { |e| render_exception_without_logging(HttpErrors::CONFLICT, e) }

  # support for session (thread-local) variables must be the last filter in this class
  include Util::ThreadSession::Controller
  include AuthorizationRules


  protected

  def exception_with_response(exception)
    logger.error "exception when talking to a remote client: #{exception.message} " << pp_exception(exception)
    if request_from_katello_cli?
      # TODO: why not use http_code from the exception???
      render :json => format_subsys_exception_hash(exception), :status => 400
    else
      render :text => exception.response , :status => exception.http_code
    end
  end

  def format_subsys_exception_hash(exception)
    orig_hash = JSON.parse(exception.response).with_indifferent_access rescue {}

    orig_hash[:displayMessage] = exception.response.to_s.gsub(/^"|"$/, "") if orig_hash[:displayMessage].nil? && exception.respond_to?(:response)
    orig_hash[:displayMessage] = exception.message if orig_hash[:displayMessage].blank?
    orig_hash[:errors] = [orig_hash[:displayMessage]] if orig_hash[:errors].nil?
    orig_hash
  end

  def render_403(e)
    render :text => pp_exception(e) , :status => HttpErrors::FORBIDDEN
  end

  def process_invalid(exception)
    logger.error exception.class
    logger.debug exception.backtrace.join("\n")
    errors = case exception
    when Katello.config.use_foreman && Resources::ForemanModel::Invalid
      exception.resource.errors
    when ActiveRecord::RecordInvalid
      exception.record.errors
    else
      raise ArgumentError.new("Expected ForemanModel::Invalid or ActiveRecord::RecordInvalid exception.")
    end

    # TODO RAILS32 Clean up if-else
    if errors.respond_to?(:messages)
      errors.messages.each_pair do |c,e|
        logger.error "#{c}: #{e}"
      end
    else
      errors.each_pair do |c,e|
        logger.error "#{c}: #{e}"
      end
    end

    respond_to do |format|
      format.json { render :json => {:displayMessage => exception.message, :errors => [exception.message] }, :status => HttpErrors::UNPROCESSABLE_ENTITY }
      format.all  { render :text => pp_exception(exception, :with_class => false), :status => HttpErrors::UNPROCESSABLE_ENTITY }
    end
  end

  def record_not_found(exception)
    logger.error(pp_exception(exception))
    logger.debug exception.backtrace.join("\n")

    respond_to do |format|
      format.json { render :json => {:displayMessage => exception.message, :errors => [exception.message] }, :status => HttpErrors::NOT_FOUND }
      format.all  { render :text => pp_exception(exception, :with_class => false), :status => HttpErrors::NOT_FOUND }
    end
  end

  def render_wrapped_exception(ex)
    logger.error "*** ERROR: #{ex.message} (#{ex.status_code}) ***"
    logger.error "REQUEST URL: #{request.fullpath}"
    logger.error pp_exception(ex.original.nil? ? ex : ex.original)
    orig_message = (ex.original.nil? && '') || ex.original.message
    format_text_orig_message = (orig_message.blank?) ? '' : " (#{orig_message})"
    respond_to do |format|
      format.json { render :json => {:displayMessage => ex.message, :errors => [ ex.message, orig_message ]}, :status => ex.status_code }
      format.all { render :text => "#{ex.message}#{format_text_orig_message}", :status => ex.status_code }
    end
  end

  def render_exception_without_logging(status_code, exception)
    respond_to do |format|
      #json has to be displayMessage for older RHEL 5.7 subscription managers
      format.json { render :json => {:displayMessage => exception.message, :errors => [exception.message] }, :status => status_code }
      format.all  { render :text => exception.message, :status => status_code }
    end
  end

  def render_exception(status_code, exception)
    logger.error pp_exception(exception)
    render_exception_without_logging(status_code, exception)
  end

  def pp_exception(exception, options = { })
    options = options.reverse_merge(:with_class => true, :with_body => true, :with_backtrace => true)
    message = ""
    message << "#{exception.class}: " if options[:with_class]
    message << "#{exception.message}\n"
    message << "Body: #{exception.http_body}\n" if options[:with_body] && exception.respond_to?(:http_body)
    message << exception.backtrace.join("\n") if options[:with_backtrace]
    message
  end

end
