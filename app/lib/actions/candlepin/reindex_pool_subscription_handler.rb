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
  module Candlepin
    class ReindexPoolSubscriptionHandler

      def initialize(logger)
        @logger = logger
      end

      def handle(message)
        @logger.debug("message received from subscriptions queue ")
        @logger.debug("message subject: #{message.subject}")

        ::User.current = ::User.anonymous_admin

        case message.subject
        when /entitlement\.(deleted|created)$/
          index_pool(message)
        end
      end

      def index_pool(message)
        content = JSON.parse(message.content)
        pool_id = content['referenceId']
        pool = ::Katello::Pool.find_pool(pool_id)
        @logger.info "re-indexing #{pool_id}."
        ::Katello::Pool.index_pools([pool])
      end
    end
  end
end
