module Katello
  module Errors
    class PingError < StandardError; end

    class InvalidActionOptionError < StandardError; end

    class InvalidRepositoryContent < StandardError; end

    class NotFound < StandardError; end

    class RegistrationError < StandardError; end

    class InvalidRepositoryTypeError < StandardError; end

    class MultiEnvironmentNotSupportedError < StandardError; end

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

    class HostRegisteredException < StandardError
      def message
        _("Content host must be unregistered before performing this action.")
      end
    end

    class EmptyBulkActionException < StandardError
      def message
        _("No hosts registered with subscription-manager found in selection.")
      end
    end

    class PulpcoreMissingCapabilities < StandardError
      def message
        _("A smart proxy seems to have been refreshed without pulpcore being running. Please refresh the smart proxy after ensuring that pulpcore services are running.")
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

    class CandlepinNotRunning < StandardError; end
    class CandlepinPoolGone < CandlepinError; end
    class CandlepinEnvironmentGone < CandlepinError; end

    class Pulp3Error < StandardError; end
    class Pulp3MigrationError < StandardError; end
    class Pulp3ExportError < StandardError; end

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

    class UpstreamCandlepinError < CandlepinError; end

    class UpstreamConsumerGone < StandardError
      def message
        _("The manifest doesn't exist on console.redhat.com. " \
          "Please create and import a new manifest.")
      end
    end

    class UpstreamConsumerNotFound < StandardError; end

    class UpstreamEntitlementGone < StandardError; end

    class ContainerRegistryNotConfigured < StandardError
      def message
        _("No URL found for a container registry. Please check the configuration.")
      end
    end

    class SubscriptionConnectionNotEnabled < StandardError
      def message
        _("Access to Red Hat Subscription Management " \
        "is prohibited. If you would like to change this, please update the content setting 'Subscription connection enabled'.")
      end
    end

    class NoManifestImported < StandardError
      def message
        _("Current organization does not have a manifest imported.")
      end
    end

    class ManifestExpired < StandardError
      def message
        _("This Organization's subscription manifest has expired. Please import a new manifest.")
      end
    end
  end
end
