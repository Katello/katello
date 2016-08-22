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

    class ImportPoolHandler
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
          import_pool(wrapped_message.content['referenceId'])
        when /entitlement\.deleted/
          import_or_remove_pool(wrapped_message.content['referenceId'])
        when /pool\.created/
          import_pool(wrapped_message.content['entityId'])
        when /pool\.deleted/
          remove_pool(wrapped_message.content['entityId'])
        when /compliance\.created/
          reindex_consumer(wrapped_message)
        end
      end

      private

      def import_or_remove_pool(pool_id)
        pool = ::Katello::Pool.find_by(:cp_id => pool_id)
        pool.nil? ? remove_pool(pool_id) : pool.import_data
      rescue RestClient::ResourceNotFound
        remove_pool(pool_id)
      end

      def import_pool(pool_id)
        ::Katello::Pool.import_pool(pool_id)
      rescue RestClient::ResourceNotFound
        @logger.debug "skipped re-index of non-existent pool #{pool_id}"
      end

      def remove_pool(pool_id)
        pool = ::Katello::Pool.find_by(:cp_id => pool_id)
        if pool
          pool.destroy!
        else
          @logger.debug "Couldn't find pool with candlepin id #{pool_id} in the database"
        end
      end

      def reindex_consumer(message)
        if message.content['newEntity']
          uuid = JSON.parse(message.content['newEntity'])['consumer']['uuid']
          skip_msg = "skip re-indexing of non-existent content host #{uuid}"
          begin
            subscription_facet = ::Katello::Host::SubscriptionFacet.find_by_uuid(uuid)
            if subscription_facet.nil?
              @logger.debug "skip re-indexing of non-existent registered host #{uuid}"
            else
              @logger.debug "re-indexing content host #{subscription_facet.host.name}"
              subscription_facet.update_subscription_status
            end
          rescue RestClient::ResourceNotFound, RestClient::Gone
            @logger.debug(skip_msg)
          end
        end
      end
    end
  end
end
