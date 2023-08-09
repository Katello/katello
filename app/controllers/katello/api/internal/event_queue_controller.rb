module Katello
  module Api
    module Internal
      class EventQueueController < ::Katello::Api::InternalApiController
        before_action :authorize_foreman_client

        def reset
          EventQueue.reset_in_progress
        end

        def subscribe
          subscription = Katello::EventQueue::Subscription.new
          result = subscription.wait

          if result
            render json: 'ok'
          else
            head :no_content
          end
        end

        def next
          event = ::Katello::EventQueue.next_event

          unless event
            return head :no_content
          end

          ::User.as_anonymous_admin do
            handler = Katello::EventQueue::Handler.new(event)
            handler.handle
          end

          render json: { event: event }
        end

        def heartbeat
          if params[:status].present?
            Rails.cache.write(::Katello::Ping::CANDLEPIN_EVENTS_CACHE_KEY, params[:status], expires_in: 1.minute)
          end
        end
      end
    end
  end
end
