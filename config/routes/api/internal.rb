Katello::Engine.routes.draw do
  scope module: :api, path: :api do
    scope module: :internal, path: :internal do
      scope path: :event_queue, as: :event_queue do
        match '/heartbeat' => 'event_queue#heartbeat', via: :post
        match '/next' => 'event_queue#next', via: :post
        match '/reset' => 'event_queue#reset', via: :post
        match '/subscribe' => 'event_queue#subscribe', via: :get
      end

      scope path: :candlepin_events, as: :candlepin_events do
        match '/handle' => 'candlepin_events#handle', via: :post
        match '/heartbeat' => 'candlepin_events#heartbeat', via: :post
      end
    end
  end
end
