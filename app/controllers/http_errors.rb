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

module HttpErrors

  class WrappedError < StandardError
    attr_reader :original

    def initialize(msg, original=$!)
      super(msg)
      @original = original
    end
  end

  # application general errors
  class AppError < WrappedError; end
  class ApiError < AppError; end

  # specific errors
  class NotFound < WrappedError; end
  class BadRequest < WrappedError; end
  class Conflict < WrappedError; end
  class UnprocessableEntity < WrappedError; end

end
