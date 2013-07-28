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

module Katello
  module HttpErrors

    BAD_REQUEST          = 400
    UNAUTHORIZED         = 401
    FORBIDDEN            = 403
    NOT_FOUND            = 404
    CONFLICT             = 409
    UNPROCESSABLE_ENTITY = 422
    INTERNAL_ERROR       = 500
    SERVICE_UNAVAILABLE  = 503

    class WrappedError < StandardError
      class_attribute :status_code
      attr_reader :original

      def initialize(msg, original=$!)
        super(msg)
        @original = original
      end
    end

    class BadRequest < WrappedError
      self.status_code = BAD_REQUEST
    end

    class Unauthorized < WrappedError
      self.status_code = UNAUTHORIZED
    end

    class Forbidden < WrappedError
      self.status_code = FORBIDDEN
    end

    class NotFound < WrappedError
      self.status_code = NOT_FOUND
    end

    class Conflict < WrappedError
      self.status_code = CONFLICT
    end

    class UnprocessableEntity < WrappedError
      self.status_code = UNPROCESSABLE_ENTITY
    end

    class InternalError < WrappedError
      self.status_code = INTERNAL_ERROR
    end

    class ServiceUnavailable < WrappedError
      self.status_code = SERVICE_UNAVAILABLE
    end
  end
end
