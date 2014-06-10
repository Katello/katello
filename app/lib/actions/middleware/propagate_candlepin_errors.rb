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

module Actions
  module Middleware

    class PropagateCandlepinErrors < Dynflow::Middleware

      def plan(*args)
        propagate_candlepin_errors { pass(*args) }
      end

      def run(*args)
        propagate_candlepin_errors { pass(*args) }
      end

      def finalize
        propagate_candlepin_errors { pass(*args) }
      end

      private

      def propagate_candlepin_errors
        yield
      rescue RestClient::ExceptionWithResponse => e
        raise(::Katello::Errors::CandlepinError.from_exception(e) || e)
      end

    end
  end
end
