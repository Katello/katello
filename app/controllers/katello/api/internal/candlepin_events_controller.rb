module Katello
  module Api
    module Internal
      class CandlepinEventsController < ::Katello::Api::InternalApiController
        before_action :authorize_foreman_client

        def handle
          event = OpenStruct.new(params.slice(:subject, :content))
          handler = ::Katello::Candlepin::EventHandler.new(Katello.internal_events_logger)
          handler.handle(event)
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
