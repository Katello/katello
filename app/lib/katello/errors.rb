module Katello
  module Errors
    class InvalidActionOptionError < StandardError; end

    class InvalidRepositoryContent < StandardError; end

    class InvalidPuppetModuleError < InvalidRepositoryContent; end

    class NotFound < StandardError; end

    class RegistrationError < StandardError; end

    # unauthorized access
    class SecurityViolation < StandardError; end

    class UserNotSet < SecurityViolation; end

    class OrchestrationException < StandardError; end

    class TemplateContentException < StandardError; end

    class TemplateExportException < StandardError; end

    class ChangesetContentException < StandardError; end

    class CapsuleContentMissingConsumer < StandardError; end

    class CdnSubstitutionError < StandardError; end

    class ConflictException < StandardError; end

    class ContentViewRepositoryOverlap < StandardError; end

    class ContentViewTaskInProgress < StandardError; end

    class HostCollectionEmptyException < StandardError
      def message
        _("Host collection is empty.")
      end
    end

    class EmptyBulkActionException < StandardError
      def message
        _("No hosts registered with subscription-manager found in selection.")
      end
    end

    class ConnectionRefusedException < StandardError; end

    class MaxHostsReachedException < StandardError; end

    class OrganizationDestroyException < StandardError; end

    class CapsuleCannotBeReached < StandardError; end

    class UnsupportedActionException < StandardError
      attr_reader :action, :receiver

      def initialize(action, receiver, message)
        @action, @receiver = action, receiver
        super(message)
      end
    end

    class TemplateValidationException < StandardError
      attr_accessor :errors

      def initialize(msg, errors = [])
        @errors = errors
        super(msg)
      end

      def message
        if @errors.nil?
          "#{to_s}: " + _("No errors")
        else
          "#{to_s}: #{errors.join(', ')}"
        end
      end
    end

    class PuppetConflictException < StandardError
      attr_accessor :conflicts

      def initialize(conflicts)
        self.conflicts = conflicts
      end
    end

    class CandlepinError < StandardError
      # Return a CandlepinError with the displayMessage
      # as the message set it
      def self.from_exception(exception)
        error_data = MultiJson.load(exception.response)
        if (display_message = error_data["displayMessage"])
          self.new(display_message).tap { |e| exception.set_backtrace(e.backtrace) }
        end
      rescue StandardError
        return nil
      end
    end

    class PulpError < StandardError
      def self.from_task(task)
        if %w(error canceled).include?(task[:state])
          message = if task[:exception]
                      Array(task[:exception]).join('; ')
                    elsif task[:error]
                      "#{task[:error][:code]}: #{task[:error][:description]}"
                    elsif task[:state] == 'canceled'
                      _("Task canceled")
                    else
                      _("Pulp task error")
                    end
          self.new(message)
        end
      end
    end

    class UpstreamConsumerGone < StandardError
      def message
        _("The Subscription Allocation providing the imported manifest has been removed. " \
          "Please create a new Subscription Allocation and import the new manifest.")
      end
    end

    class UpstreamEntitlementGone < StandardError; end
  end
end
