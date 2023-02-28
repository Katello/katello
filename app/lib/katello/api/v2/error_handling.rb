module Katello
  module Api
    module V2
      module ErrorHandling
        extend ActiveSupport::Concern

        included do
          rescue_from Exception, :with => :rescue_from_exception          # catch-all
          rescue_from StandardError, :with => :rescue_from_standard_error # catch-all *almost*
          rescue_from HttpErrors::WrappedError, :with => :rescue_from_wrapped_error

          rescue_from RestClient::ExceptionWithResponse, :with => :rescue_from_exception_with_response
          rescue_from ActiveRecord::RecordInvalid, :with => :rescue_from_record_invalid
          rescue_from ActiveRecord::RecordNotFound, :with => :rescue_from_record_not_found

          rescue_from HttpErrors::BadRequest, :with => :rescue_from_unsupported_action_exception
          rescue_from HttpErrors::NotFound, :with => :rescue_from_not_found
          rescue_from Errors::NotFound, :with => :rescue_from_not_found
          rescue_from Errors::SecurityViolation, :with => :rescue_from_security_violation
          rescue_from Errors::ConflictException, :with => :rescue_from_conflict_exception
          rescue_from Errors::UnsupportedActionException, :with => :rescue_from_unsupported_action_exception
          rescue_from Errors::MaxHostsReachedException, :with => :rescue_from_max_hosts_reached_exception
          rescue_from Errors::CdnSubstitutionError, :with => :rescue_from_bad_data
          rescue_from Katello::Pulp3::ContentViewVersion::ExportValidationError, :with => :rescue_from_export_validation_error
          rescue_from Errors::RegistrationError, :with => :rescue_from_bad_data
          rescue_from ActionController::ParameterMissing, :with => :rescue_from_missing_param
          rescue_from ::ForemanTasks::Lock::LockConflict, :with => :rescue_from_bad_data
        end

        protected

        def rescue_from_missing_param(exception)
          text = "Missing values for #{exception.param}."
          respond_for_exception(exception, :text => text, :display_message => text, :status => :bad_request)
        end

        def rescue_from_exception(exception)
          text = 'Fatal Error: See logs for details or contact system administrator'
          respond_for_exception(exception, :text => text, :display_message => text, :status => :internal_server_error)
        end

        def rescue_from_standard_error(exception)
          respond_for_exception(exception, :status => :internal_server_error)
        end

        def rescue_from_wrapped_error(exception)
          logger.error "*** ERROR: #{exception.message} (#{exception.status_code}) ***"
          logger.error "REQUEST URL: #{request.fullpath}"
          logger.error pp_exception(exception.original.nil? ? exception : exception.original)

          orig_message             = (exception.original.nil? && '') || exception.original.message
          format_text_orig_message = orig_message.blank? ? '' : " (#{orig_message})"
          text                     = "#{exception.message}#{format_text_orig_message}"

          respond_for_exception(exception, :text => text, :errors => [exception.message, orig_message], :with_logging => false)
        end

        def rescue_from_exception_with_response(exception)
          logger.error "exception when talking to a remote client: #{exception.message} " << pp_exception(exception)
          if request_from_katello_cli?
            # TODO: why not use http_code from the exception???
            render :json => format_subsys_exception_hash(exception), :status => :bad_request
          else
            respond_for_exception(exception, :status => :bad_request)
          end
        end

        def rescue_from_not_found(exception)
          respond_for_exception(exception, :status => :not_found)
        end

        def rescue_from_security_violation(exception)
          logger.warn pp_exception(exception, :with_body => false, :with_backtrace => false)
          respond_for_exception(exception, :status => :forbidden, :with_logging => false)
        end

        def rescue_from_unsupported_action_exception(exception)
          respond_for_exception(exception, :status => :bad_request)
        end

        def rescue_from_bad_data(exception)
          respond_for_exception(exception, :status => :unprocessable_entity)
        end

        def rescue_from_max_hosts_reached_exception(exception)
          respond_for_exception(exception, :status => :conflict, :with_logging => false)
        end

        def rescue_from_export_validation_error(exception)
          respond_for_exception(exception, :force_json => true, :status => :unprocessable_entity)
        end

        def rescue_from_conflict_exception(exception)
          respond_for_exception(exception, :status => :conflict)
        end

        def rescue_from_record_invalid(exception)
          logger.error exception.class

          errors = case exception
                   when ActiveRecord::RecordInvalid
                     exception.record.errors
                   else
                     fail ArgumentError, "ActiveRecord::RecordInvalid exception."
                   end

          errors.messages.each_pair do |c, e|
            logger.error "#{c}: #{e}"
          end

          text = pp_exception(exception, :with_class => false)
          respond_for_exception(exception, :status => :unprocessable_entity, :text => text, :with_logging => false)
        end

        def rescue_from_record_not_found(exception)
          text = pp_exception(exception, :with_class => false)
          respond_for_exception(exception, :status => :not_found, :text => text)
        end

        def respond_for_exception(exception, options = {})
          options = options.reverse_merge(
              :with_logging    => true,
              :status          => exception.respond_to?('status_code') ? exception.status_code : :internal_server_error,
              :text            => exception.message,
              :display_message => exception.message)

          options[:errors] = exception.try(:record).try(:errors) || [exception.message]

          logger.error pp_exception(exception) if options[:with_logging]
          respond_to do |format|
            #json has to be displayMessage for older RHEL 5.7 subscription managers
            format.json { render :json => { :displayMessage => options[:display_message], :errors => options[:errors]}, :status => options[:status] }
            format.all do
              if options[:force_json]
                render :json => { :displayMessage => options[:display_message], :errors => options[:errors]}, :status => options[:status]
              else
                render :plain => options[:text], :status => options[:status]
              end
            end
          end
        end

        def pp_exception(exception, options = {})
          options = options.reverse_merge(:with_class => true, :with_body => true, :with_backtrace => true)
          message = ""
          message << "#{exception.class}: " if options[:with_class]
          message << "#{exception.message}\n"
          message << "Body: #{exception.http_body}\n" if options[:with_body] && exception.respond_to?(:http_body)
          message << exception.backtrace.join("\n") if options[:with_backtrace]
          message
        end

        def format_subsys_exception_hash(exception)
          orig_hash = JSON.parse(exception.response).with_indifferent_access rescue {}

          orig_hash[:displayMessage] = exception.response.to_s.gsub(/^"|"$/, "") if orig_hash[:displayMessage].nil? && exception.respond_to?(:response)
          orig_hash[:displayMessage] = exception.message if orig_hash[:displayMessage].blank?
          orig_hash[:errors] = [orig_hash[:displayMessage]] if orig_hash[:errors].nil?
          orig_hash
        end
      end
    end
  end
end
