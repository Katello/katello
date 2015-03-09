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
    class MessageWrapper
      attr_accessor :message

      def initialize(message)
        @message = message
      end

      def subject
        @message.subject
      end

      def content
        JSON.parse(@message.content)
      end
    end

    class ReindexPoolSubscriptionHandler
      TEN_SECONDS = 10
      FIVE_ATTEMPTS = 5
      def initialize(logger)
        @logger = logger
      end

      def handle(message)
        @logger.debug("message received from subscriptions queue ")
        @logger.debug("message subject: #{message.subject}")

        ::User.current = ::User.anonymous_admin

        wrapped_message = MessageWrapper.new(message)
        case message.subject
        when /entitlement\.(deleted|created)$/
          reindex_pool_based_on_entitlement(wrapped_message)
        when /pool\.created/
          pool_created(wrapped_message)
        when /pool\.deleted/
          remove_pool_from_index(wrapped_message)
        end
      end

      private

      def remove_pool_from_index(message)
        @logger.info "removing pool from index #{message.subject}."
        remove_pool_from_index_by_pool_id(message.content['entityId'])
      end

      def pool_created(message)
        pool_id = message.content['entityId']
        @logger.debug "creating index for pool #{pool_id}."
        reindex_pool(pool_id)
        @logger.debug "pools in index #{pools_in_my_index.to_s}."
      end

      def reindex_pool_based_on_entitlement(message)
        pool_id = message.content['referenceId']
        @logger.info "re-indexing pools[#{pool_id}] for entitlement[#{message.content['entityId']}]."
        reindex_pool(pool_id)
      end

      def reindex_pool(pool_id)
        @logger.info "re-indexing pool #{pool_id}."
        pool = ::Katello::Pool.find_pool(pool_id)
        ::Katello::Pool.index_pools([pool]) unless pool.unmapped_guest
      end

      def remove_pool_from_index_by_pool_id(pool_id)
        @logger.info "removing pool from index #{pool_id}."
        ::Katello::Pool.remove_from_index(pool_id)
      end

      def pools_in_my_index
        ::Katello::Pool.search.map { |p| p.id }
      end
    end
  end
end
