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

class Api::V1::ApiController < Api::ApiController

  include Api::Version1

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


  # remove unwanted parameters 'action' and 'controller' from params list and return it
  # and convert true/false strings to boolean types
  # note: you can use expected_params = params.slice('name') instead
  def query_params
    return @query_params if @query_params

    @query_params = params.clone
    @query_params.delete('controller')
    @query_params.delete('action')

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

  protected

  def find_organization
    @organization = find_optional_organization
    raise HttpErrors::NotFound, _("One of parameters [%s] required but not specified.") %
      organization_id_keys.join(", ") if @organization.nil?
    @organization
  end

  def find_optional_organization
    org_id = organization_id
    return if org_id.nil?

    @organization = get_organization(org_id)
    raise HttpErrors::NotFound, _("Couldn't find organization '%s'") % org_id if @organization.nil?
    @organization
  end

  def organization_id_keys
    return [:organization_id]
  end

  private

  def get_organization org_id
    # name/label is always unique
    return Organization.without_deleting.having_name_or_label(org_id).first
  end

  def organization_id
    key = organization_id_keys.find {|k| not params[k].nil? }
    return params[key]
  end

  def find_content_view_definition
    cvd_id = params[:content_view_definition_id]
    @definition = ContentViewDefinition.find_by_id(cvd_id)
    if @definition.nil?
      raise HttpErrors::NotFound, _("Couildn't find content view with id '%s'") % cvd_id
    end
  end

  def find_content_filter_by_name
    filter_id = params[:filter_id]
    @filter = Filter.where(:name => filter_id, :content_view_definition_id => @definition).first
    raise HttpErrors::NotFound, _("Couldn't find filter '%s'") % params[:id] if @filter.nil?
    @filter
  end


  def find_optional_environment
    @environment = KTEnvironment.find_by_id(params[:environment_id]) if params[:environment_id]
  end

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
    when ActiveRecord::RecordInvalid
      exception.record.errors
    else
      raise ArgumentError.new("ActiveRecord::RecordInvalid exception.")
    end

    errors.messages.each_pair do |c,e|
      logger.error "#{c}: #{e}"
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

  # Get the :label value from the params hash if it exists
  # otherwise use the :name value and convert to ASCII
  def labelize_params(params)
    return params[:label] unless params.try(:[], :label).nil?
    return Util::Model::labelize(params[:name]) unless params.try(:[], :name).nil?
  end

  def respond_for_index(options={})
    collection = options[:collection] || get_resource_collection
    status = options[:status] || 200
    format = options[:format] || :json

    render format => collection, :status => status
  end

  def respond_for_show(options={})
    resource = options[:resource] || get_resource
    status = options[:status] || 200
    format = options[:format] || :json

    render format => resource, :status => status
  end

  def respond_for_create(options={})
    respond_for_show(options)
  end

  def respond_for_update(options={})
    respond_for_show(options)
  end

  def respond_for_destroy(options={})
    respond_for_status(options)
  end

  def respond_for_status(options={})
    message = options[:message] || nil
    status = options[:status] || 200
    format = options[:format] || :text

    render format => message, :status => status
  end

end
