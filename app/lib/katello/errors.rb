#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  module Errors
    class InvalidRepositoryContent < StandardError; end

    class InvalidPuppetModuleError < InvalidRepositoryContent; end

    class NotFound < StandardError; end

    # unauthorized access
    class SecurityViolation < StandardError; end

    class UserNotSet < SecurityViolation; end

    class OrchestrationException < StandardError; end

    class TemplateContentException < StandardError; end

    class TemplateExportException < StandardError; end

    class ChangesetContentException < StandardError; end

    class CapsuleContentMissingConsumer < StandardError; end

    class ConflictException < StandardError; end

    class ContentViewRepositoryOverlap < StandardError; end

    class ContentViewTaskInProgress < StandardError; end

    class HostCollectionEmptyException < StandardError
      def message
        _("Host collection is empty.")
      end
    end

    class ConnectionRefusedException < StandardError; end

    class MaxContentHostsReachedException < StandardError; end

    class OrganizationDestroyException < StandardError; end

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

      def errors
        return @errors
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
        if display_message = error_data["displayMessage"]
          self.new(display_message).tap { |e| exception.set_backtrace(e.backtrace) }
        end
      rescue StandardError
        return nil
      end
    end

    class PulpError < StandardError
      def self.from_task(task)
        if task[:state] == 'error'
          message = if task[:exception]
                      Array(task[:exception]).join('; ')
                    elsif task[:error]
                      "#{task[:error][:code]}: #{task[:error][:description]}"
                    else
                      _("Pulp task error")
                    end
          self.new(message)
        end
      end
    end
  end
end
