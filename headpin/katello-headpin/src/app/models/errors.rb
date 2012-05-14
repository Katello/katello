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

module Errors
  class NotFound < StandardError; end

  # unauthorized access
  class SecurityViolation < StandardError; end
  class BadParameters < HttpErrors::BadRequest
    attr_accessor :broken_params, :params
    def initialize broken_params, params
      @broken_params = broken_params
      @params = Support.scrub(Support.deep_copy(params)) do |key, value|
        String === value && key.to_s.downcase =~ /password|authenticity_token/
      end
      super BadParameters.generate_message @broken_params, @params
    end

    def self.generate_message broken_params, params
      _("Wrong/Invalid parameters sent for %s/%s.\n Wrong Parameters: \n%s\n Parameters Received:\n %s ") % [params[:controller],params[:action], broken_params.inspect, params.inspect]
    end
  end

  class UserNotSet < SecurityViolation; end

  class OrchestrationException < StandardError; end

  class TemplateContentException < StandardError; end

  class TemplateExportException < StandardError; end

  class ChangesetContentException < StandardError; end

  class ConflictException < StandardError; end

  class CurrentOrganizationNotFoundException < ActiveRecord::RecordNotFound; end

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
end
