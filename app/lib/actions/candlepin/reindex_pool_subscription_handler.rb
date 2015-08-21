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
      def initialize(logger)
        @logger = logger
      end

      def handle(message)
        @logger.debug("message received from subscriptions queue ")
        @logger.debug("message subject: #{message.subject}")

        ::User.current = ::User.anonymous_admin

        wrapped_message = MessageWrapper.new(message)
        case message.subject
        when /entitlement\.created/
          reindex_pool(wrapped_message.content['referenceId'])
        when /entitlement\.deleted/
          reindex_or_unindex_pool(wrapped_message.content['referenceId'])
        when /pool\.created/
          reindex_pool(wrapped_message.content['entityId'])
        when /pool\.deleted/
          unindex_pool(wrapped_message.content['entityId'])
        when /compliance\.created/
          reindex_consumer(wrapped_message)
        end
      end

      private

      def reindex_or_unindex_pool(pool_id)
        ::Katello::Pool.find_pool(pool_id)
        reindex_pool(pool_id)
      rescue RestClient::ResourceNotFound
        unindex_pool(pool_id)
      end

      def reindex_pool(pool_id)
        @logger.info "re-indexing pool #{pool_id}."
        pool = ::Katello::Pool.find_pool(pool_id)
        ::Katello::Pool.index_pools([pool]) unless pool.nil? || pool.unmapped_guest
      rescue RestClient::ResourceNotFound
        @logger.debug "skipped re-index of non-existent pool #{pool_id}"
      end

      def unindex_pool(pool_id)
        @logger.info "removing pool from index #{pool_id}."
        ::Katello::Pool.remove_from_index(pool_id)
      end

      def reindex_consumer(message)
        if message.content['newEntity']
          uuid = JSON.parse(message.content['newEntity'])['consumer']['uuid']
          system = ::Katello::System.find_by(:uuid => uuid)
          if system.nil?
            @logger.debug "skip re-indexing of non-existent content host #{uuid}"
          else
            @logger.debug "re-indexing content host #{system.name}"
            system.update_index
          end
        end
      end
    end
  end
end
